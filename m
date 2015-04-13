From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v4 05/24] rocker: use swdev get/set attr for
 bridge port flags
Date: Mon, 13 Apr 2015 12:48:00 +0200
Message-ID: <20150413104800.GB2090@nanopsycho.lan>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
 <1428905838-14920-6-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com, andrew@lunn.ch
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:36536 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753575AbbDMKsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 06:48:03 -0400
Received: by wizk4 with SMTP id k4so67011847wiz.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 03:48:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1428905838-14920-6-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 13, 2015 at 08:16:59AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
> drivers/net/ethernet/rocker/rocker.c |   31 +++++++++++++++++++++++++++++--
> 1 file changed, 29 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>index 80c7f6f..9bd4fc6 100644
>--- a/drivers/net/ethernet/rocker/rocker.c
>+++ b/drivers/net/ethernet/rocker/rocker.c
>@@ -359,6 +359,8 @@ static void *__rocker_port_alloc(struct rocker_port *rocker_port,
> 		if (elem)
> 			INIT_LIST_HEAD(elem);
> 		break;
>+	default:
>+		break;
> 	}
> 
> 	return elem ? elem + 1 : NULL;
>@@ -4332,6 +4334,9 @@ static int rocker_port_attr_get(struct net_device *dev, struct swdev_attr *attr)
> 		attr->ppid.id_len = sizeof(rocker->hw.id);
> 		memcpy(&attr->ppid.id, &rocker->hw.id, attr->ppid.id_len);
> 		break;
>+	case SWDEV_ATTR_PORT_BRIDGE_FLAGS:


This patch should be squashed with the previous one (04)
