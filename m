From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] lwtunnel: use kfree_skb() instead of vanilla
 kfree()
Date: Mon, 27 Jul 2015 01:25:19 -0700 (PDT)
Message-ID: <20150727.012519.1095992977174899951.davem@davemloft.net>
References: <20150727080747.GA2937@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39158 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbbG0IZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:25:19 -0400
In-Reply-To: <20150727080747.GA2937@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 27 Jul 2015 11:07:47 +0300

> kfree_skb() is correct here.
> 
> Fixes: ffce41962ef6 ('lwtunnel: support dst output redirect function')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Oops, good catch.  Applied, thanks Dan.
