From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 4/7] bridge: define some min/max ageing time
 constants we'll use next
Date: Sat, 19 Sep 2015 08:45:07 +0200
Message-ID: <20150919064507.GD2067@nanopsycho.orion>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
 <1442606151-50429-5-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, siva.mannem.lnx@gmail.com,
	pjonnala@broadcom.com, stephen@networkplumber.org,
	roopa@cumulusnetworks.com, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:37031 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbbISGpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 02:45:09 -0400
Received: by wicfx3 with SMTP id fx3so53630222wic.0
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 23:45:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1442606151-50429-5-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 18, 2015 at 09:55:48PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
> include/linux/if_bridge.h |    4 ++++
> 1 file changed, 4 insertions(+)
>
>diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
>index dad8b00..6cc6dbc 100644
>--- a/include/linux/if_bridge.h
>+++ b/include/linux/if_bridge.h
>@@ -46,6 +46,10 @@ struct br_ip_list {
> #define BR_LEARNING_SYNC	BIT(9)
> #define BR_PROXYARP_WIFI	BIT(10)
> 
>+/* values as per ieee8021QBridgeFdbAgingTime */
>+#define BR_MIN_AGEING_TIME	(10 * HZ)
>+#define BR_MAX_AGEING_TIME	(1000000 * HZ)

I think that a bridge patch checking against these values should be
introduced along with these values, in the same patchset
