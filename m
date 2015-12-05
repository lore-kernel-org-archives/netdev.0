From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Sat, 05 Dec 2015 01:49:09 -0500 (EST)
Message-ID: <20151205.014909.1572453190886968569.davem@davemloft.net>
References: <CAKgT0UepW=VehhXncrAM=tvqrVDD_KOdVJBpwEU+hYTAdMz_dg@mail.gmail.com>
	<CALx6S36Y4fP9a6U40My+kuhik5THPOjHNYfRrVe8Szte03K7Ew@mail.gmail.com>
	<566279E5.9070500@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, hannes@stressinduktion.org,
	linville@tuxdriver.com, jesse@kernel.org, anjali.singhai@intel.com,
	netdev@vger.kernel.org, kiran.patil@intel.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54997 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbbLEGtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 01:49:14 -0500
In-Reply-To: <566279E5.9070500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 4 Dec 2015 21:45:09 -0800

> Not having this feature has to in some way impact sales.

I'm glad money trumps clean design and performance these days.

Would they ship a literal turd until some customer asked for
something better?  You have to be kidding me.

If it's true, then what a sad world we live in.

And part of this is bogus, the circuit is already there and
implemented already.  The missing part is putting the value computed
by that circuit into the receive descriptor.

And furthermore, nobody is going to drop to BSD or DPDK for VXLAN
tunnels just because I push back hard on this facility.
