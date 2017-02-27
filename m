From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] qed: Bug fixes
Date: Mon, 27 Feb 2017 09:22:50 -0500 (EST)
Message-ID: <20170227.092250.180035328583447492.davem@davemloft.net>
References: <1488186393-3938-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42618 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751783AbdB0Ocf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 09:32:35 -0500
In-Reply-To: <1488186393-3938-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Mon, 27 Feb 2017 11:06:31 +0200

> Hi Dave,
> 
> Patch #1 addresses a day-one race which is dependent on the number of Vfs
> [I.e., more child VFs from a single PF make it more probable].
> Patch #2 corrects a race that got introduced in the last set of fixes for
> qed, one that would happen each time PF transitions to UP state.
> 
> I've built & tested those against current net-next.
> Please consider applying the series there.

The net-next tree is closed, and bug fixes are supposed to target
the net tree so that's where I've applied these changes.

Please target the correct tree in the future, thanks.
