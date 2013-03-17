From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [Patch net-next] net: fix some typos in netif features
Date: Sat, 16 Mar 2013 19:45:05 -0700
Message-ID: <CALnjE+rrVK_4b=puiQjD2NAKJvjfmjnfG4O2u9UU5XD_OUPfCw@mail.gmail.com>
References: <1363445275-3917-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:60268 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753934Ab3CQCpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 22:45:07 -0400
Received: by mail-ve0-f200.google.com with SMTP id ox1so8486602veb.3
        for <netdev@vger.kernel.org>; Sat, 16 Mar 2013 19:45:05 -0700 (PDT)
In-Reply-To: <1363445275-3917-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 16, 2013 at 7:47 AM, Cong Wang <amwang@redhat.com> wrote:
> From: Cong Wang <amwang@redhat.com>
>
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
>
Looks good.

Acked-by: Pravin B Shelar <pshelar@nicira.com>

> ---
>
> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
> index f5e797c..d6ee2d0 100644
> --- a/include/linux/netdev_features.h
> +++ b/include/linux/netdev_features.h
> @@ -102,8 +102,8 @@ enum {
>  #define NETIF_F_VLAN_CHALLENGED        __NETIF_F(VLAN_CHALLENGED)
>  #define NETIF_F_RXFCS          __NETIF_F(RXFCS)
>  #define NETIF_F_RXALL          __NETIF_F(RXALL)
> -#define NETIF_F_GRE_GSO                __NETIF_F(GSO_GRE)
> -#define NETIF_F_UDP_TUNNEL     __NETIF_F(UDP_TUNNEL)
> +#define NETIF_F_GSO_GRE                __NETIF_F(GSO_GRE)
> +#define NETIF_F_GSO_UDP_TUNNEL __NETIF_F(GSO_UDP_TUNNEL)
>
>  /* Features valid for ethtool to change */
>  /* = all defined minus driver/device-class-related */
