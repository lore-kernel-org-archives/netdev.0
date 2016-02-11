From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2] bonding: use return instead of goto
Date: Thu, 11 Feb 2016 09:57:24 -0500 (EST)
Message-ID: <20160211.095724.1673577316117980850.davem@davemloft.net>
References: <1455014266-17190-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53437 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbcBKO51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 09:57:27 -0500
In-Reply-To: <1455014266-17190-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Tue,  9 Feb 2016 10:37:46 +0000

> Replace 'goto' with 'return' to remove unnecessary check at label:
> err_undo_flags.
> 
> The reason is that 'err_undo_flags' do two things for the first slave device:
> 1.revert bond mac address if it is set by the slave device.
> 2.revert bond device type if it's not ARPHRD_ETHER.
> 
> It's not necessary for the following three places, they changed neither bond 
> mac address nor type. It's straightforward to return directly.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied, thanks.
