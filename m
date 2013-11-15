From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v2] net: ethernet: ti/cpsw: do not crash on single-MAC
 machines during resume
Date: Fri, 15 Nov 2013 14:18:42 +0530
Message-ID: <5285DFEA.6030105@ti.com>
References: <1384500556-11634-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <ujhelyi.m@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>
To: Daniel Mack <zonque@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:52360 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754893Ab3KOIst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Nov 2013 03:48:49 -0500
In-Reply-To: <1384500556-11634-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 15 November 2013 12:59 PM, Daniel Mack wrote:
> During resume, use for_each_slave to walk the slaves of the cpsw, and
> soft-reset each of them. This prevents oopses if there is only one
> slave configured.
>
> Signed-off-by: Daniel Mack <zonque@gmail.com>
Acked-by: Mugunthan V N <mugunthanvnm@gmail.com>

Regards
Mugunthan V N
