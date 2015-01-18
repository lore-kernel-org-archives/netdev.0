From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] socket: use ki_nbytes instead of iov_length()
Date: Sat, 17 Jan 2015 23:58:59 -0500 (EST)
Message-ID: <20150117.235859.1813288428938454235.davem@davemloft.net>
References: <20150115214519.GB29656@ZenIV.linux.org.uk>
	<1421415309-4639-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbbARE7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 23:59:00 -0500
In-Reply-To: <1421415309-4639-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 16 Jan 2015 14:35:09 +0100

> This field already contains the length of the iovec, no need to calculate it
> again.
> 
> Suggested-by: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
