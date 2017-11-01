From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tun/tap: sanitize TUNSETSNDBUF input
Date: Wed, 01 Nov 2017 20:53:34 +0900 (KST)
Message-ID: <20171101.205334.528454363401742419.davem@davemloft.net>
References: <20171030225011.184639-1-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52462 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752246AbdKALxi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 07:53:38 -0400
In-Reply-To: <20171030225011.184639-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Mon, 30 Oct 2017 18:50:11 -0400

> From: Craig Gallek <kraig@google.com>
> 
> Syzkaller found several variants of the lockup below by setting negative
> values with the TUNSETSNDBUF ioctl.  This patch adds a sanity check
> to both the tun and tap versions of this ioctl.
 ...
> Fixes: 33dccbb050bb ("tun: Limit amount of queued packets per device")
> Fixes: 20d29d7a916a ("net: macvtap driver")
> Signed-off-by: Craig Gallek <kraig@google.com>

Applied and queued up for -stable, thanks.
