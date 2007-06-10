From: "Leonid Grossman" <Leonid.Grossman@neterion.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Sun, 10 Jun 2007 11:27:09 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7701B7D6D1@nekter>
References: <1181168020.4064.46.camel@localhost> <D5C1322C3E673F459512FB59E0DDC32902FC61BF@orsmsx414.amr.corp.intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD7701B7D69C@nekter> <1181417000.4043.34.camel@localhost> <78C9135A3D2ECE4B8162EBDCE82CAD7701B7D6BC@nekter> <1181444559.4043.91.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Patrick McHardy" <kaber@trash.net>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>,
	"Alex Aizman" <aaizman@neterion.com>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:57679 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752060AbXFJP3W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2007 11:29:22 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1181444559.4043.91.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: J Hadi Salim [mailto:j.hadi123@gmail.com] On Behalf Of jamal
> Sent: Saturday, June 09, 2007 8:03 PM
> To: Leonid Grossman
> Cc: Waskiewicz Jr, Peter P; Patrick McHardy; davem@davemloft.net;
> netdev@vger.kernel.org; jeff@garzik.org; Kok, Auke-jan H; Ramkrishna
> Vepa; Alex Aizman
> Subject: RE: [PATCH] NET: Multiqueue network device support.
> 
> our definition of "channel" on linux so far is a netdev
> (not a DMA ring). A netdev is the entity that can be bound to a CPU.
> Link layer flow control terminates (and emanates) from the netdev.

I think we are saying the same thing. Link layer flow control frames are
generated (and terminated) by the hardware; the hardware gets configured
by netdev.
And if a hw channel has enough resources, it could be configured as a
separate netdev and handle it's flow control the same way single-channel
NICs do now. 
I'm not advocating flow control on per DMA ring basis. 

> > This is not what I'm saying :-). The IEEE link you sent shows that
> > per-link flow control is a separate effort, and it will likely to
> take
> > time to become a standard.
> 
> Ok, my impression was it was happening already or it will happen
> tommorow morning ;->

the proposal you mentioned is dated 2005, but something like that will
probably happen sooner or later in IEEE. Some non-standard options,
including ours, are already here - but as we just discussed, in any case
flow control is arguably a netdev property not a queue property. 
The multi-queue patch itself though (and possibly some additional
per-queue properties) is a good thing :-)
 

