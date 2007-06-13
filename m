From: "Leonid Grossman" <Leonid.Grossman@neterion.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Wed, 13 Jun 2007 11:01:11 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7701B7DE05@nekter>
References: <466DEF9D.9070509@trash.net> <1181615384.4071.121.camel@localhost> <466E9DF2.9010505@trash.net> <20070612.140240.00078635.davem@davemloft.net> <466F0D74.5030308@trash.net> <1181714168.4758.57.camel@debian.sh.intel.com> <1181737935.4050.87.camel@localhost> <18031.60741.695897.572432@robur.slu.se> <1181741602.4050.116.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhu Yi" <yi.zhu@intel.com>, "Patrick McHardy" <kaber@trash.net>,
	"David Miller" <davem@davemloft.net>,
	<peter.p.waskiewicz.jr@intel.com>, <netdev@vger.kernel.org>,
	<jeff@garzik.org>, <auke-jan.h.kok@intel.com>
To: <hadi@cyberus.ca>, "Robert Olsson" <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:49272 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754887AbXFMPDk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 11:03:40 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1181741602.4050.116.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: J Hadi Salim [mailto:j.hadi123@gmail.com] On Behalf Of jamal


> For the Leonid-NIC (for lack of better name) it may be harder to do
> parallelization on rcv if you use what i said above. But you could
> use a different model on receive - such as create a single netdev and
> with 8 rcv rings and MSI tied on rcv to 8 different CPUs
> Anyways, it is an important discussion to have. ttl.

Call it "IOV-style NIC" :-)
Or something like that, it's a bit too early to talk about full IOV
compliance...
>From what I see in Intel new pci-e 10GbE driver, they have quite a few
of the same attributes, and the category is likely to grow further.
In IOV world, hw channel requirements are pretty brutal; in a nutshell
each channel could be owned by a separate OS instance (and the OS
instances do not even have to be the same type). For a non-virtualized
OS some of these capabilities are not a "must have", but they are/will
be there and Linux may as well take advantage of it.
Leonid

> 
> cheers,
> jamal
> 

