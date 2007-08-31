From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 5/5] Net: ath5k, kconfig changes
Date: Fri, 31 Aug 2007 10:32:14 -0400
Message-ID: <1188570734.4347.15.camel@xo-3E-67-34.localdomain>
References: <2713029743177393055@pripojeni.net>
	 <280951420471148977@pripojeni.net> <20070828171330.GD29343@infradead.org>
	 <40f31dec0708291838p5d33eb34p3b4432d9d270841a@mail.gmail.com>
	 <20070830123609.GA5140@tuxdriver.com>
	 <1188561531.2668.7.camel@xo-3E-67-34.localdomain>
	 <46D8180A.5070902@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	Christoph Hellwig <hch@infradead.org>,
	Jiri Slaby <jirislaby@gmail.com>, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50736 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754172AbXHaOiv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 10:38:51 -0400
In-Reply-To: <46D8180A.5070902@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-08-31 at 09:30 -0400, Jeff Garzik wrote:
> Dan Williams wrote:
> > On Thu, 2007-08-30 at 08:36 -0400, John W. Linville wrote:
> >> On Thu, Aug 30, 2007 at 04:38:09AM +0300, Nick Kossifidis wrote:
> >>> 2007/8/28, Christoph Hellwig <hch@infradead.org>:
> >>>> Also this whole patch seems rather pointless.  It saves only
> >>>> very little and turns the driver into a complete ifdef maze.
> >>> Also most
> >>> people will use 5212 code only, 5211 cards are on some old laptops and
> >>> 5210, well i couldn't even find  a 5210 for actual testing :P
> >> FWIW, I'd bet dollars to donuts that distros will enable them all
> >> together.
> > 
> > I would certainly _hope_ that distros enable everything -that is in the
> > kernel- that they can get their hands on, otherwise when you stick a
> > card in, it doesn't just work.
> 
> Distros definitely -do not- do this.  Plenty of ancient ISA drivers are 
> disabled at build time, for example, in many distros.

Ok, so let me qualify to "within reason".  All 802.11-compliant wireless
cards would fall within the "within reason" IMHO, but, for example,
older non 802.11 wireless cards (early Aironet products for example)
probably don't.  ISA clearly does not for mainstream distros.

Dan


