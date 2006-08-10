From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] limit rt cache size
Date: Wed, 09 Aug 2006 17:02:29 -0700 (PDT)
Message-ID: <20060809.170229.68041648.davem@davemloft.net>
References: <200608090302.19634.ak@suse.de>
	<Pine.LNX.4.61.0608090913410.2452@localhost.localdomain>
	<200608091832.26492.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, kuznet@ms2.inr.ac.ru, dev@sw.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:60036
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932076AbWHJACl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 20:02:41 -0400
To: ak@suse.de
In-Reply-To: <200608091832.26492.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Wed, 9 Aug 2006 18:32:26 +0200

> One issue I forgot earlier and Kirill pointed out is that the
> reallocation would require vmalloc because memory will be too fragmented
> to get a big piece of physical memory. So it would add TLB pressure. 
> 
> Can't think of a good way around that.
> 
> You might have been right with being sceptical.

For NUMA this already happens, is it a problem in practice?
