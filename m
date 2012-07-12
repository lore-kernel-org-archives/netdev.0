From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] tcp: update a call to tcp_metric_set()
Date: Thu, 12 Jul 2012 07:50:43 -0700 (PDT)
Message-ID: <20120712.075043.633614495014183744.davem@davemloft.net>
References: <20120712144637.GA24202@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932528Ab2GLOuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 10:50:44 -0400
In-Reply-To: <20120712144637.GA24202@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 12 Jul 2012 17:46:38 +0300

> We changed how the metrics were stored so RTAX_CWND needs to be changed
> to TCP_METRIC_CWND or it leads to write past the end of the
> ->tcpm_vals[] array.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Update your tree, this is already fixed.
