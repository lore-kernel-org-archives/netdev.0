From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [Madwifi-devel] ar5k and Atheros AR5005G
Date: Wed, 29 Nov 2006 08:03:28 -0800
Message-ID: <20061129160328.GA22602@devicescape.com>
References: <1164746352.31456.22.camel@systems03.lan.brontes3d.com> <200611291612.33448.mb@bu3sch.de> <20061129152407.GB5412@devicescape.com> <200611291638.56759.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Kimdon <david.kimdon@devicescape.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	Daniel Drake <ddrake@brontes3d.com>, netdev@vger.kernel.org,
	madwifi-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:34025 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S935842AbWK2QDb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 11:03:31 -0500
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200611291638.56759.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 29, 2006 at 04:38:56PM +0100, Michael Buesch wrote:
> On Wednesday 29 November 2006 16:24, David Kimdon wrote:
> > On Wed, Nov 29, 2006 at 04:12:33PM +0100, Michael Buesch wrote:
> > > On Wednesday 29 November 2006 15:34, Nick Kossifidis wrote:
> > Why do you say that?
> > 
> > There is absolutely no reason why dadwifi can't be merged into the
> > mainline once the hal issue is resolved. 
> 
> Last time we talked about that stuff, it was decided that
> we don't want a HAL... See archives.

To be clear, that is all part of the hal issue that needs to be
resolved.  Removing the hal abstraction is not difficult for an
interested party once source for the hal is available.  The next step
in such an effort would be to add an open hal to dadwifi, IMO.

-David

P.S. Actually, it isn't clear to me that removing the hal entirely is
a good idea.  Abstractions exist for practical reasons.  The hal
allows dadwifi to support a variety of Atheros chips without needing
to worry about the specific details of each chip.
