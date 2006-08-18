From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Fri, 18 Aug 2006 01:51:23 -0700 (PDT)
Message-ID: <20060818.015123.104036098.davem@davemloft.net>
References: <20060816142557.acccdfcf.ak@suse.de>
	<Pine.LNX.4.64.0608171920220.28680@schroedinger.engr.sgi.com>
	<200608181129.15075.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clameter@sgi.com, hch@infradead.org, johnpol@2ka.mipt.ru,
	arnd@arndb.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:33494
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751270AbWHRIwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 04:52:08 -0400
To: ak@suse.de
In-Reply-To: <200608181129.15075.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Fri, 18 Aug 2006 11:29:14 +0200

> So ideal would be something dynamic to turn on/off io placement, maybe based 
> on node_distance() again, with the threshold tweakable per architecture?

We have this ugly 'hashdist' thing, let's remove the __initdata tag
on it, give it a useful name, and let architectures set it as
they deem appropriate.
