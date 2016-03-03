From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next V2 01/10] net/flower: Introduce hardware offload
 support
Date: Thu, 3 Mar 2016 15:57:01 +0100
Message-ID: <20160303145701.GB4431@nanopsycho.orion>
References: <1457016960-27832-1-git-send-email-amir@vadai.me>
 <1457016960-27832-2-git-send-email-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36432 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754583AbcCCO5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 09:57:04 -0500
Received: by mail-wm0-f68.google.com with SMTP id l68so4499715wml.3
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 06:57:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1457016960-27832-2-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 03, 2016 at 03:55:51PM CET, amir@vadai.me wrote:
>This patch is based on a patch made by John Fastabend.
>It adds support for offloading cls_flower.
>when NETIF_F_HW_TC is on:
>  flags = 0       => Rule will be processed twice - by hardware, and if
>                     still relevant, by software.
>  flags = SKIP_HW => Rull will be processed by software only
>
>If hardare fail/not capabale to apply the rule, operation will fail.
>
>Suggested-by: John Fastabend <john.r.fastabend@intel.com>
>Signed-off-by: Amir Vadai <amir@vadai.me>

Acked-by: Jiri Pirko <jiri@mellanox.com>
