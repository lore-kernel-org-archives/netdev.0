From: pravin shelar <pshelar@ovn.org>
Subject: Re: [net-next] ovs: set name assign type of internal port
Date: Thu, 2 Jun 2016 12:49:36 -0700
Message-ID: <CAOrHB_DaQonV04JT1TKRz7+dNEp810eyL8K-QEFWWFBa=-Xggg@mail.gmail.com>
References: <1464702062-7220-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:53341 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932378AbcFBTtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 15:49:40 -0400
Received: from mfilter19-d.gandi.net (mfilter19-d.gandi.net [217.70.178.147])
	by relay3-d.mail.gandi.net (Postfix) with ESMTP id BDC65A80CB
	for <netdev@vger.kernel.org>; Thu,  2 Jun 2016 21:49:38 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
	by mfilter19-d.gandi.net (mfilter19-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id OlAeOM_EQiJQ for <netdev@vger.kernel.org>;
	Thu,  2 Jun 2016 21:49:37 +0200 (CEST)
Received: from mail-it0-f44.google.com (mail-it0-f44.google.com [209.85.214.44])
	(Authenticated sender: pshelar@ovn.org)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 57DE3A80D2
	for <netdev@vger.kernel.org>; Thu,  2 Jun 2016 21:49:37 +0200 (CEST)
Received: by mail-it0-f44.google.com with SMTP id z189so119947172itg.0
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 12:49:37 -0700 (PDT)
In-Reply-To: <1464702062-7220-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 31, 2016 at 6:41 AM, Zhang Shengju
<zhangshengju@cmss.chinamobile.com> wrote:
> Set name_assign_type of internal port to NET_NAME_USER.
>
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>  net/openvswitch/vport-internal_dev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
> index 2ee48e4..434e04c 100644
> --- a/net/openvswitch/vport-internal_dev.c
> +++ b/net/openvswitch/vport-internal_dev.c
> @@ -195,7 +195,7 @@ static struct vport *internal_dev_create(const struct vport_parms *parms)
>         }
>
>         vport->dev = alloc_netdev(sizeof(struct internal_dev),
> -                                 parms->name, NET_NAME_UNKNOWN, do_setup);
> +                                 parms->name, NET_NAME_USER, do_setup);

Looks good.
Acked-by: Pravin B Shelar <pshelar@ovn.org>
