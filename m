From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 3/5] neigh: store parms type inside the
 structure
Date: Fri, 06 Dec 2013 15:08:40 -0500 (EST)
Message-ID: <20131206.150840.2078088427369267519.davem@davemloft.net>
References: <1386354544-19122-1-git-send-email-jiri@resnulli.us>
	<1386354544-19122-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org, bcrl@kvack.org,
	william.manley@youview.com, gaofeng@cn.fujitsu.com,
	joe@perches.com, herbert@gondor.apana.org.au
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279Ab3LFUIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 15:08:42 -0500
In-Reply-To: <1386354544-19122-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  6 Dec 2013 19:29:02 +0100

> There is going to be needed later on to distinguish parms instance
> between ipv4 and ipv6. So just store the type inside.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Please just use neigh_parms->tbl->family.

Thanks.
