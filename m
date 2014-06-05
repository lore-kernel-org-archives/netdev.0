From: Bing Zhao <bzhao@marvell.com>
Subject: RE: [PATCH] mwifiex: Remove custom world regulatory domain
Date: Thu, 5 Jun 2014 00:12:58 -0700
Message-ID: <477F20668A386D41ADCC57781B1F70430F768A292B@SC-VEXCH1.marvell.com>
References: <1401888752-11224-1-git-send-email-mpa@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: Markus Pargmann <mpa@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:64199 "EHLO
	mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750939AbaFEHNN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 03:13:13 -0400
In-Reply-To: <1401888752-11224-1-git-send-email-mpa@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Markus,

Thanks for the patch.

> A custom regulatory domain was introduced in this commit:
> cc0ba0d mwifiex: support custom world regulatory domain
> 
> The commit description says that it was introduced because the world
> regulatory domain does not include channels 52-64 and 100-140. These
> channels are described in the world regulatory domain now, so we can drop
> this custom regulatory domain.
> 
> Signed-off-by: Markus Pargmann <mpa@pengutronix.de>

Acked-by: Bing Zhao <bzhao@marvell.com>

Thanks,
Bing

> ---
>  drivers/net/wireless/mwifiex/cfg80211.c | 36 ---------------------------------
>  1 file changed, 36 deletions(-)
