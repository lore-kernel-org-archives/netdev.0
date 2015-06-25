From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] cavium/liquidio: fix some error handling in
 lio_set_phys_id()
Date: Thu, 25 Jun 2015 02:13:30 -0700 (PDT)
Message-ID: <20150625.021330.1433395634367960208.davem@davemloft.net>
References: <20150624144702.GH1702@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, sgoutham@cavium.com,
	rric@kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbbFYJBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 05:01:38 -0400
In-Reply-To: <20150624144702.GH1702@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 24 Jun 2015 17:47:02 +0300

> There was a missing assignment so the "if (ret)" on the next line is
> never true.
> 
> Fixes: f21fb3ed364b ('Add support of Cavium Liquidio ethernet adapters')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
