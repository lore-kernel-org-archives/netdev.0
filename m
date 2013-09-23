From: Bing Zhao <bzhao@marvell.com>
Subject: RE: [PATCH 11/19] wireless: Change variable type to bool
Date: Mon, 23 Sep 2013 12:40:33 -0700
Message-ID: <477F20668A386D41ADCC57781B1F70430F44C59426@SC-VEXCH1.marvell.com>
References: <1379802471-30252-1-git-send-email-peter.senna@gmail.com>
 <1379802471-30252-11-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:47168 "EHLO
	mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753281Ab3IWTko convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 15:40:44 -0400
In-Reply-To: <1379802471-30252-11-git-send-email-peter.senna@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peter,

Thanks for your patch.

> The variables cancel_scan_cmd, enable_data, hs_activate and valid are
> only assigned the values true and false. Change its type to bool.
> 
> The simplified semantic patch that find this problem is as
> follows (http://coccinelle.lip6.fr/):
> 
> @exists@
> type T;
> identifier b;
> @@
> - T
> + bool
>   b = ...;
>   ... when any
>   b = \(true\|false\)
> 
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

Acked-by: Bing Zhao <bzhao@marvell.com>

Thanks,
Bing

> ---
>  drivers/net/wireless/mwifiex/cmdevt.c  | 2 +-
>  drivers/net/wireless/mwifiex/join.c    | 2 +-
>  drivers/net/wireless/mwifiex/sta_cmd.c | 2 +-
>  drivers/net/wireless/mwifiex/wmm.c     | 2 +-
>  4 files changed, 4 insertions(+), 4 deletions(-)
