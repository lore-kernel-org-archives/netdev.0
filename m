From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] renesas: missing unlock on error path
Date: Thu, 25 Jun 2015 02:13:24 -0700 (PDT)
Message-ID: <20150625.021324.1080187390583121565.davem@davemloft.net>
References: <20150624143254.GG1702@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: masaru.nagai.vx@renesas.com, sergei.shtylyov@cogentembedded.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbbFYJBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 05:01:32 -0400
In-Reply-To: <20150624143254.GG1702@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 24 Jun 2015 17:32:54 +0300

> We need to unlock before returning here.
> 
> Fixes: a0d2f20650e8 ('Renesas Ethernet AVB PTP clock driver')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
