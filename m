From: Jie Yang <Jie.Yang@Atheros.com>
Subject: RE: [PATCH?] atl1e: WAKE_MCAST 2x. 1st WAKE_UCAST?
Date: Fri, 8 Aug 2008 11:12:20 +0800
Message-ID: <72981EBCFD196144B7C6999B9FC34A9A3EE61F99BC@SHEXMB-01.global.atheros.com>
References: <489B21CA.7010508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"jacliburn@bellsouth.net" <jacliburn@bellsouth.net>
To: roel kluin <roel.kluin@gmail.com>,
	"jgarzik@redhat.com" <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 175.212.DSNET ([203.110.175.212]:12379 "EHLO mail.atheros.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751239AbYHHDMY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 23:12:24 -0400
In-Reply-To: <489B21CA.7010508@gmail.com>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, August 08, 2008 12:25 AM
roel kluin <roel.kluin@gmail.com> wrote

>
> untested, is it right?
> ---
> WAKE_MCAST bit tested twice, test WAKE_UCAST first.
>
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com> diff --git
> a/drivers/net/atl1e/atl1e_ethtool.c
> b/drivers/net/atl1e/atl1e_ethtool.c
> index cdc3b85..619c658 100644
> --- a/drivers/net/atl1e/atl1e_ethtool.c
> +++ b/drivers/net/atl1e/atl1e_ethtool.c
> @@ -355,7 +355,7 @@ static int atl1e_set_wol(struct
> net_device *netdev, struct ethtool_wolinfo *wol)
>         struct atl1e_adapter *adapter = netdev_priv(netdev);
>
>         if (wol->wolopts & (WAKE_ARP | WAKE_MAGICSECURE |
> -                           WAKE_MCAST | WAKE_BCAST | WAKE_MCAST))
> +                           WAKE_UCAST | WAKE_MCAST | WAKE_BCAST))
>                 return -EOPNOTSUPP;
>         /* these settings will always override what we
> currently have */
>         adapter->wol = 0;
>

Yes, it should be this, thanks!

Acked-by: Jie Yang <jie.yang@atheros.com>

BTW: resend on the comments from Jay Cliburn <jacliburn@bellsouth.net>

Thanks Jay
