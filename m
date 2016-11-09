From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qed: Prevent stack corruption on MFW
 interaction
Date: Wed, 09 Nov 2016 13:27:45 -0500 (EST)
Message-ID: <20161109.132745.2191587840450609497.davem@davemloft.net>
References: <1478445147-23163-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38502 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754016AbcKIS1q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:27:46 -0500
In-Reply-To: <1478445147-23163-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Sun, 6 Nov 2016 17:12:27 +0200

> Driver uses a union for copying data to & from management firmware
> when interacting with it.
> Problem is that the function always copies sizeof(union) while commit
> 2edbff8dcb5d ("qed: Learn resources from management firmware") is casting
> a union elements which is of smaller size [24-byte instead of 88-bytes].
> 
> Also, the union contains some inappropriate elements which increase its
> size [should have been 32-bytes]. While this shouldn't corrupt other
> PF messages to the MFW [as management firmware enforces permissions so
> that each PF is allowed to write only to its own mailbox] we fix this
> here as well.
> 
> Fixes: 2edbff8dcb5d ("qed: Learn resources from management firmware")
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Applied.
