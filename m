From: Glen Turner <gdt@gdt.id.au>
Subject: Re: [PATCH] Re: [PATCH] drivers/net: remove network drivers' last
	few uses of IRQF_SAMPLE_RANDOM
Date: Mon, 26 May 2008 00:56:42 +0930
Message-ID: <1211729202.5913.81.camel@andromache>
References: <87abirytxj.fsf@basil.nowhere.org>
	 <20080516105635.6cb1f505@core> <482D5FC5.2070103@firstfloor.org>
	 <20080516121239.GA9627@gondor.apana.org.au>
	 <482DB568.1040704@firstfloor.org>
	 <20080517010136.GA15102@gondor.apana.org.au>
	 <482EBAA8.3040506@firstfloor.org>
	 <a24804730805171254i2a37da61mb47280db7b330ed5@mail.gmail.com>
	 <20080517130535.02d45372@infradead.org> <4830014F.9040800@firstfloor.org>
	 <20080518112657.GK16496@mit.edu>  <48306D36.6040706@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Theodore Tso <tytso@mit.edu>,
	Arjan van de Ven <arjan@infradead.org>,
	Chris Peterson <cpeterso@cpeterso.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	tpmdd-devel@lists.sourceforge.net, tpm@selhorst.net
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:45487 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752972AbYEYP3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2008 11:29:11 -0400
In-Reply-To: <48306D36.6040706@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-05-18 at 19:53 +0200, Andi Kleen wrote:
> I never quite understood the rationale behind that one either:
> if you worry about someone else controlling the timing of these events,
> why do you not worry about timings on the local system. e.g.
> it's not that hard to predict with similar accuracy when a hard disk
> interrupt happened when a local process read something from disk. Or
> when the  keyboard/USB interrupt happened when you process keyboard input.

Accepting packets requires you to trust another party -- the network
provider and users of your host's networked services -- which you do
not have to trust otherwise.

