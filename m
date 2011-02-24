From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Network driver for PMC-Sierra MSP71xx TSMAC.
Date: Thu, 24 Feb 2011 09:35:35 -0800
Message-ID: <20110224093535.744ebaf7@nehalam>
References: <1298548660-10546-1-git-send-email-anoop.pa@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, khilman@deeprootsystems.com, cyril@ti.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mips@linux-mips.org
To: "Anoop P.A" <anoop.pa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43459 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752573Ab1BXRfi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Feb 2011 12:35:38 -0500
In-Reply-To: <1298548660-10546-1-git-send-email-anoop.pa@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Feb 2011 17:27:40 +0530
"Anoop P.A" <anoop.pa@gmail.com> wrote:
> +const char version[] = "pmcmsp_tsmac.c:v2.0 01/09/2007, PMC-Sierra\n";
> +const char cardname[] = "pmcmsp_tsmac";

All data and functions that are only used by this driver should be marked static.

> +const char drv_reldate[] = "$Date: 2010/07/15 07:38:59 $";
> +const char drv_file[] = __FILE__;

This is bogus noise.


-- 
