From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Update netdev_alloc_frag to work more efficiently
 with TCP and GRO
Date: Wed, 20 Jun 2012 02:04:01 -0700 (PDT)
Message-ID: <20120620.020401.1089501454050120720.davem@davemloft.net>
References: <1340170590.4604.784.camel@edumazet-glaptop>
	<1340180223.4604.828.camel@edumazet-glaptop>
	<1340181847.4604.840.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35884 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755583Ab2FTJEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 05:04:04 -0400
In-Reply-To: <1340181847.4604.840.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Jun 2012 10:44:07 +0200

> (put_page assumes order-0 page)

But it certainly can handle compound pages, I thought?
