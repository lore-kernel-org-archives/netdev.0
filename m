From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 1/3] bridge: new mode flag to indicate mode
 'undefined'
Date: Tue, 9 Dec 2014 08:54:28 +0100
Message-ID: <20141209075428.GB1974@nanopsycho.orion>
References: <1418076261-24593-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	linville@tuxdriver.com, vyasevic@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:46292 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbaLIHya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 02:54:30 -0500
Received: by mail-wi0-f172.google.com with SMTP id n3so6949719wiv.17
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 23:54:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1418076261-24593-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Dec 08, 2014 at 11:04:19PM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>This patch adds mode BRIDGE_MODE_UNDEF for cases where mode is not needed.
>
>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>

>
>---
> include/uapi/linux/if_bridge.h |    1 +
> 1 file changed, 1 insertion(+)
>
>diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
>index 296a556..05f0869 100644
>--- a/include/uapi/linux/if_bridge.h
>+++ b/include/uapi/linux/if_bridge.h
>@@ -106,6 +106,7 @@ struct __fdb_entry {
> #define BRIDGE_MODE_VEB		0	/* Default loopback mode */
> #define BRIDGE_MODE_VEPA	1	/* 802.1Qbg defined VEPA mode */
> #define BRIDGE_MODE_SWDEV	2	/* Full switch device offload */
>+#define BRIDGE_MODE_UNDEF	0xFFFF  /* mode undefined */
> 
> /* Bridge management nested attributes
>  * [IFLA_AF_SPEC] = {
>-- 
>1.7.10.4
>
