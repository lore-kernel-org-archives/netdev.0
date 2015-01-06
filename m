From: David Miller <davem@davemloft.net>
Subject: Re: route/max_size sysctl in ipv4
Date: Mon, 05 Jan 2015 19:36:14 -0500 (EST)
Message-ID: <20150105.193614.1827024424476781168.davem@davemloft.net>
References: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ani@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325AbbAFAgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 19:36:18 -0500
In-Reply-To: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ani Sinha <ani@arista.com>
Date: Mon, 5 Jan 2015 15:48:11 -0800

> I am looking at the code and it looks like since the route cache for
> ipv4 was removed from the kernel, this sysctl parameter no longer
> serves the same purpose. It does not look like it is even used in the
> ipv4/route.c module. Is there an equivalent sysctl parameter limiting
> the number of route entries in the kernel? Or is there now no
> mechanism to limit the number of route entries?

There is nothing to limit, since the cache was removed.
