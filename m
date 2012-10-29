From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] ipv6: remove useless test in dev_forward_change()
Date: Mon, 29 Oct 2012 11:07:39 +0100
Message-ID: <508E556B.8030602@6wind.com>
References: <20121029015709.GA18567@localhost> <1351502649-3876-1-git-send-email-nicolas.dichtel@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:37975 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976Ab2J2KHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 06:07:43 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so2315898wey.19
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 03:07:42 -0700 (PDT)
In-Reply-To: <1351502649-3876-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please ignore, the patch has already be sent by Cong Wang <amwang@redha=
t.com>.

Le 29/10/2012 10:24, Nicolas Dichtel a =C3=A9crit :
> idev->dev cannot be NULL.
>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>   net/ipv6/addrconf.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 8f0b12a..c9b1cf3 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -607,7 +607,7 @@ static void dev_forward_change(struct inet6_dev *=
idev)
>   	dev =3D idev->dev;
>   	if (idev->cnf.forwarding)
>   		dev_disable_lro(dev);
> -	if (dev && (dev->flags & IFF_MULTICAST)) {
> +	if (dev->flags & IFF_MULTICAST) {
>   		if (idev->cnf.forwarding)
>   			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
>   		else
>
