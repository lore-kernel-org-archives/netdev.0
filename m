From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vti: get rid of nf mark rule in prerouting
Date: Fri, 11 Oct 2013 14:53:04 -0400 (EDT)
Message-ID: <20131011.145304.305063991853045981.davem@davemloft.net>
References: <1381245682-15523-1-git-send-email-christophe.gouault@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com, saurabh@vyatta.com
To: christophe.gouault@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846Ab3JKSxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 14:53:06 -0400
In-Reply-To: <1381245682-15523-1-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe Gouault <christophe.gouault@6wind.com>
Date: Tue,  8 Oct 2013 17:21:22 +0200

> This patch fixes and improves the use of vti interfaces (while
> lightly changing the way of configuring them).
 ...
> Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
> ---
> This is is both a fix and enhancement patch. However, there are 2 ways
> of fixing the inbound processing bug:
> - either keep the current configuration model (ikey + netfilter rule)
>   and change the tunnel lookup method. This patch would then be reverted
>   by the enhancement (this sounds counterproductive).
> - or directly change the configuration model (okey, no netfilter rule) and keep
>   the current tunnel lookup method.

Ok, applied and queued up for -stable, thanks.
