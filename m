From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 15/21] net: mac80211_hwsim: convert to using IFF_NO_QUEUE
Date: Tue, 18 Aug 2015 10:43:55 +0200
Message-ID: <1439887435.2455.0.camel@sipsolutions.net>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
	 <1439886649-24166-2-git-send-email-phil@nwl.cc>
	 <1439886649-24166-3-git-send-email-phil@nwl.cc>
	 <1439886649-24166-4-git-send-email-phil@nwl.cc>
	 <1439886649-24166-5-git-send-email-phil@nwl.cc>
	 <1439886649-24166-6-git-send-email-phil@nwl.cc>
	 <1439886649-24166-7-git-send-email-phil@nwl.cc>
	 <1439886649-24166-8-git-send-email-phil@nwl.cc>
	 <1439886649-24166-9-git-send-email-phil@nwl.cc>
	 <1439886649-24166-10-git-send-email-phil@nwl.cc>
	 <1439886649-24166-11-git-send-email-phil@nwl.cc>
	 <1439886649-24166-12-git-send-email-phil@nwl.cc>
	 <1439886649-24166-13-git-send-email-phil@nwl.cc>
	 <1439886649-24166-14-git-send-email-phil@nwl.cc>
	 <1439886649-24166-15-git-send-email-phil@nwl.cc>
	 <1439886649-24166-16-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, davem@davemloft.net
To: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49044 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751502AbbHRIoC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:44:02 -0400
In-Reply-To: <1439886649-24166-16-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-08-18 at 10:30 +0200, Phil Sutter wrote:
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> Cc: Johannes Berg <johannes@sipsolutions.net>
> ---
>  drivers/net/wireless/mac80211_hwsim.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/mac80211_hwsim.c 
> b/drivers/net/wireless/mac80211_hwsim.c
> index 99e873d..a1dbcb2 100644
> --- a/drivers/net/wireless/mac80211_hwsim.c
> +++ b/drivers/net/wireless/mac80211_hwsim.c
> @@ -2676,7 +2676,7 @@ static void hwsim_mon_setup(struct net_device 
> *dev)
>  	dev->netdev_ops = &hwsim_netdev_ops;
>  	dev->destructor = free_netdev;
>  	ether_setup(dev);
> -	dev->tx_queue_len = 0;
> +	dev->priv_flags |= IFF_NO_QUEUE;
> 
Fine with me; Dave, are you going to pick up the entire series
(presumably there was one, I only got this patch)?

Note that there's no TX possible on this particular netdev anyway.

johannes
