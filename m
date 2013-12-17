From: David Miller <davem@davemloft.net>
Subject: Re: PATCH] net: Cache align dst refcnt
Date: Tue, 17 Dec 2013 15:10:09 -0500 (EST)
Message-ID: <20131217.151009.2096477709764504937.davem@davemloft.net>
References: <alpine.DEB.2.02.1312171013050.5720@tomh.mtv.corp.google.com>
	<1387304951.19078.282.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx9tdPRRgjoGLce1wizrbsoLLgzReEPMgPqwOiXMyiHvaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782Ab3LQUKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 15:10:10 -0500
In-Reply-To: <CA+mtBx9tdPRRgjoGLce1wizrbsoLLgzReEPMgPqwOiXMyiHvaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 17 Dec 2013 11:51:02 -0800

> Definitely not hitting the bug on. In any case, I'm wondering why is
> cache alignment being hard coded here instead of using compiler
> directives?

To tightly control the size of this structure, it is one of the most
critical in the whole networking stack so any wasted bytes is a huge
deal.
