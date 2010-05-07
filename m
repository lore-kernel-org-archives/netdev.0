From: David Miller <davem@davemloft.net>
Subject: Re: [microblaze-uclinux] Re: [PATCH net-next-2.6] net: Increase
 NET_SKB_PAD to 64 bytes
Date: Thu, 06 May 2010 23:29:18 -0700 (PDT)
Message-ID: <20100506.232918.84388708.davem@davemloft.net>
References: <20100506.220221.90798296.davem@davemloft.net>
	<1273209321.2222.36.camel@edumazet-laptop>
	<m2g1d3f23371005062228y267b398cue82f518c7638929e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: microblaze-uclinux@itee.uq.edu.au, netdev@vger.kernel.org,
	hadi@cyberus.ca, therbert@google.com, monstr@monstr.eu
To: john.williams@petalogix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35921
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750742Ab0EGG3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 02:29:12 -0400
In-Reply-To: <m2g1d3f23371005062228y267b398cue82f518c7638929e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Williams <john.williams@petalogix.com>
Date: Fri, 7 May 2010 15:28:08 +1000

> There will be some patches coming from Michal that cleans all of this
> up - MicroBlaze has a configurable cacheline length, we have some
> patches that set this to the longest possible (32 bytes) in a
> conservative assumption.

32 it the old default, the new one is 64.

So either way, these settings are completely bogus.
