From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Sat, 20 Oct 2007 07:46:06 +1000
Message-ID: <1192830366.17235.2.camel@pasglop>
References: <20071015125301.GC3015@ff.dom.local>
	 <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl>
	 <20071016062108.GB1000@ff.dom.local>
	 <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl>
	 <20071017085809.GA1658@ff.dom.local>
	 <Pine.LNX.4.64N.0710171221510.28993@blysk.ds.pg.gda.pl>
	 <Pine.LNX.4.64N.0710191229510.13279@blysk.ds.pg.gda.pl>
	 <20071019143921.GB2598@ff.dom.local>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60530 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751958AbXJSVsu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 17:48:50 -0400
In-Reply-To: <20071019143921.GB2598@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Actually I'm not convinced with this explanation. It seems to me that
> since there are such serious locking problems (especially with rntl),
> there could be once more considered a private workqueue. You've
> written earlier about being a lonely user of this code. But, since
> Benjamin offered his help with changing to mutexes, which looks like
> very reasonable idea to me (probably I miss most of the points...),
> maybe it's very good opportunity to both: make this code better and
> double the user base! I'm interested in looking for such solution
> if Benjamin thinks there could be too few problems for him... So,
> let somebody tell us what could be wrong with this idea?

My main problem is time :-) But I need to do the change to mutex if I am
to use phylib for emac. I can't tell when I'll have time to do it tho.

Ben.

