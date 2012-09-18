From: David Miller <davem@davemloft.net>
Subject: Re: [net] e1000: Small packets may get corrupted during padding by
 HW
Date: Mon, 17 Sep 2012 23:03:00 -0400 (EDT)
Message-ID: <20120917.230300.653531213751776624.davem@davemloft.net>
References: <50578DE4.7080806@intel.com>
	<1347915723.26523.179.camel@edumazet-glaptop>
	<5057E3F2.5090504@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alexander.h.duyck@intel.com,
	tushar.n.dave@intel.com, john.r.fastabend@intel.com,
	mirqus@gmail.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36110 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932121Ab2IRDDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 23:03:02 -0400
In-Reply-To: <5057E3F2.5090504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 17 Sep 2012 20:01:06 -0700

> Since MAX_TCP_HEADER starts at 160 the likelihood of it not getting
> at least 16 bytes of padding is pretty low.

I know it's not on many people's radar, but with SLOB it will happen
a lot probably.
