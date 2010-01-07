From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Thu, 7 Jan 2010 20:36:07 +0100
Message-ID: <20100107193607.GC3208@del.dom.local>
References: <4B457711.1040008@majjas.com>
 <4B458B36.6050509@majjas.com>
 <20100107074756.GB6258@ff.dom.local>
 <4B459368.2000503@majjas.com>
 <4B45F841.8030407@majjas.com>
 <20100107180114.GB3088@del.dom.local>
 <4B4625BD.3070202@majjas.com>
 <20100107183545.GA3208@del.dom.local>
 <4B462B3C.90506@majjas.com>
 <20100107185040.GB3208@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:65216 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386Ab0AGTgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 14:36:13 -0500
Content-Disposition: inline
In-Reply-To: <20100107185040.GB3208@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2010 at 07:50:40PM +0100, Jarek Poplawski wrote:
> > Going to rerun with these patches and with and without MMAP. Will
> > also retry both with jumbo frames if possible.
> 
> If MMAP then some "alternative" too. But first no MMAP.

Another things IMHO worth to try: a sky2 module parameter
"disable_msi=1", and CONFIG_DMAR off.

Jarek P.
