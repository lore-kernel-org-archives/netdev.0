From: "Vaittinen, Matti (EXT-Other - FI/Oulu)"
	<matti.vaittinen.ext@nsn.com>
Subject: RE: [PATCH] IPv6: NLM_F_* flag support for route creation/changing when using netlink.
Date: Thu, 27 Oct 2011 10:20:46 +0300
Message-ID: <82C9FC7ED59434458AD4E09AFF2DE230BF09EE@FIESEXC006.nsn-intra.net>
References: <20111027.030658.1922451477684539766.davem@davemloft.net> <9b43e0ef-21cf-4062-b998-849e9e8d6b56@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "ext Stephen Hemminger" <stephen.hemminger@vyatta.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:14060 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478Ab1J0HVF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 03:21:05 -0400
Content-class: urn:content-classes:message
In-Reply-To: <9b43e0ef-21cf-4062-b998-849e9e8d6b56@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 


> -----Original Message-----
> From: ext Stephen Hemminger [mailto:stephen.hemminger@vyatta.com] 
> Sent: Thursday, October 27, 2011 10:12 AM
> To: David Miller
> Cc: netdev@vger.kernel.org; Vaittinen, Matti (EXT-Other - FI/Oulu)
> Subject: Re: [PATCH] IPv6: NLM_F_* flag support for route
creation/changing when using netlink.
> 
> 
> > From: "Vaittinen, Matti (EXT-Other - FI/Oulu)"
> > <matti.vaittinen.ext@nsn.com>
> > Date: Thu, 27 Oct 2011 09:26:05 +0300
> > 
> > > 
> > > Will requiring NLM_F_CREATE break lots of existing userspace 
> > > software?
> > 
> > I can almost guarenetee that since we haven't been requiring this,
it 
> > will break almost everything.
> 
> Why not just make it a kernel warning for several releases.
> 
> Just checked, and iproute and quagga will have no problem since they
both already pass the CREATE flag.

For me kernel warning sounds like a reasonable approach. I will change
the patch to not drop the request with error, but to issue a warning
instead. I'll also try using better email client next time.

Furthermore I believe that most tools used for both IPv4 and IPv6
routing (like iproute) do add the CREATE flag because IPv4 route
creation does require it.
