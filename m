From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] declance: Fix 64-bit compilation warnings
Date: Mon, 07 Jul 2014 06:40:41 -0700
Message-ID: <1404740441.27043.71.camel@joe-AO725>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>
	 <20140702.182807.1245632778216212860.davem@davemloft.net>
	 <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>
	 <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
	 <1404356734.14741.18.camel@joe-AO725>
	 <alpine.LFD.2.11.1407030423300.15455@eddie.linux-mips.org>
	 <1404364565.14741.26.camel@joe-AO725>
	 <alpine.LFD.2.11.1407030637030.15455@eddie.linux-mips.org>
	 <1404368746.14741.36.camel@joe-AO725>
	 <alpine.LFD.2.11.1407051529040.15455@eddie.linux-mips.org>
	 <1404576420.6384.41.camel@joe-AO725>
	 <alpine.LFD.2.11.1407051833400.15455@eddie.linux-mips.org>
	 <1404583739.6384.51.camel@joe-AO725>
	 <alpine.LFD.2.11.1407051917480.15455@eddie.linux-mips.org>
	 <1404585099.6384.53.camel@joe-AO725>
	 <20140707120152.CF82BC40921@trevor.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0109.hostedemail.com ([216.40.44.109]:45248 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753221AbaGGNkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 09:40:46 -0400
In-Reply-To: <20140707120152.CF82BC40921@trevor.secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-07-07 at 13:01 +0100, Grant Likely wrote:
> On Sat, 05 Jul 2014 11:31:39 -0700, Joe Perches <joe@perches.com> wrote:
> > On Sat, 2014-07-05 at 19:20 +0100, Maciej W. Rozycki wrote:
> > > On Sat, 5 Jul 2014, Joe Perches wrote:
> > > > I don't think %#p is valid so it
> > > > shouldn't have been set by #.
> > > 
> > >  Huh?  As recently as last Wednesday you pointed me at the specific commit 
> > > from Grant that made it valid (GCC format complaints aside).
> > 
> > Those gcc complaints are precisely the thing
> > that makes it invalid.
> 
> That's the most inane reason ever for saying something is invalid. "The
> tool doesn't recognise it, there for it is invalid?" Seriously?

Inane maybe, but practical.

The tool says "don't do that", so we shouldn't
or we should fix or quiet the tool.

fwiw: I agree with Maciej.

gcc's warning on %#p should be able to be quieted somehow.
