From: "David Mack" <dmack@juniper.net>
Subject: RE: e100 problems in .23rc8 ?
Date: Thu, 18 Oct 2007 10:51:59 -0700
Message-ID: <7DCDA0F058071B49AED9D3D7886C41BE0966AEDB@muon.jnpr.net>
References: <470FA91F.1080302@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Dave Jones" <davej@redhat.com>, <netdev@vger.kernel.org>,
	<esandeen@redhat.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og103.obsmtp.com ([64.18.2.159]:46401 "EHLO
	exprod7og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757509AbXJRRzO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 13:55:14 -0400
Content-class: urn:content-classes:message
In-Reply-To: <470FA91F.1080302@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It appears that the needed e100 fix made it into the Fedora
2.6.23.1-23.fc8 kernel. Boots reliably now.

Huge thanks and great work, guys.

Dave

> -----Original Message-----
> From: Kok, Auke [mailto:auke-jan.h.kok@intel.com] 
> Sent: Friday, October 12, 2007 10:05 AM
> To: Herbert Xu
> Cc: David Mack; Dave Jones; netdev@vger.kernel.org; 
> esandeen@redhat.com
> Subject: Re: e100 problems in .23rc8 ?
> 
> Herbert Xu wrote:
> > On Fri, Oct 12, 2007 at 07:54:33AM -0700, David Mack wrote:
> >> Still no joy here. See attached capture. What's really 
> weird is that it
> >> shows *two* kernel panics, one in  e100_poll and one in _list_add.
> > 
> > Yes that's the symptom one would expect from that bug.  We really
> > need to apply the same fix that was done for e1000.
> 
> I feared that. its not the same as that commit that floated 
> around in this thread
> and involves some reorganization in the init/probe code, so 
> it's a bit more
> involved than just a few lines. I'll need a little bit of 
> time to generate this fix.
> 
> Auke
> 
