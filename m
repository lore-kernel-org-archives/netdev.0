From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.25 2/4]S2io: Multiqueue network device support - FIFO selection based on L4 ports
Date: Wed, 20 Feb 2008 18:49:41 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77030E313E@nekter>
References: <47BCB304.9050709@trash.net>	<20080220.151244.79005114.davem@davemloft.net>	<47BCB481.8050203@trash.net> <20080220.151834.133850272.davem@davemloft.net> <47BCB60C.3040409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	<netdev@vger.kernel.org>, <jeff@garzik.org>,
	"support" <support@neterion.com>
To: "Patrick McHardy" <kaber@trash.net>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:14766 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754338AbYBTXwU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 18:52:20 -0500
Content-class: urn:content-classes:message
In-Reply-To: <47BCB60C.3040409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Patrick McHardy [mailto:kaber@trash.net]
> Sent: Wednesday, February 20, 2008 3:22 PM
> To: David Miller
> Cc: Ramkrishna Vepa; Sreenivasa Honnur; netdev@vger.kernel.org;
> jeff@garzik.org; support
> Subject: Re: [PATCH 2.6.25 2/4]S2io: Multiqueue network device support
-
> FIFO selection based on L4 ports
> 
> David Miller wrote:
> > From: Patrick McHardy <kaber@trash.net>
> > Date: Thu, 21 Feb 2008 00:15:13 +0100
> >
> >
> >> I missed those discussions, but this has already been agreed on,
> >> fine by me. It would still be preferable to use queue_mapping
> >> instead of priority IMO, even if its activated by a module
> >> parameter, since that leaves the option to use classifiers.
> >>
> >
> > I think the driver should compute the value in it's transmit
> > routine and keep the value local.  It shouldn't be setting
> > skb->foo values at all, they don't belong to the driver
> > and this could confuse other code.
> >
> 
> Yes, I didn't meant it should set anything, but on of the options
> this patch introduces is to _use_ skb->priority for classification,
> so the classification is already external, in which case it might
> as well offer the full flexibility (as one option) to use qdisc
> classifiers.
[Ram] Yes, this should be possible. We can add an additional option to
use qdisc classifiers and submit it as a patch later on.

Ram
