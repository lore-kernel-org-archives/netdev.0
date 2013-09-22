From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 2/2] net: phy: at803x: add suspend/resume callbacks
Date: Sun, 22 Sep 2013 11:30:31 +0530
Message-ID: <523E877F.4050906@ti.com>
References: <1379775182-1271-1-git-send-email-zonque@gmail.com> <1379775182-1271-2-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <ujhelyi.m@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>
To: Daniel Mack <zonque@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:44350 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752466Ab3IVGAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Sep 2013 02:00:53 -0400
In-Reply-To: <1379775182-1271-2-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 21 September 2013 08:23 PM, Daniel Mack wrote:
> When WOL is enabled, the chip can't be put into power-down (BMCR_PDOWN)
> mode, as that will also switch off the MAC, which consequently leads to
> a link loss.
>
> Use BMCR_ISOLATE in that case, which will at least save us some
> milliamperes in comparison to normal operation mode.
>
> Signed-off-by: Daniel Mack <zonque@gmail.com>
Looks good to me

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
