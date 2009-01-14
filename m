From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 05/34]bnx2x: Setting the GSO_TYPE with LRO
Date: Wed, 14 Jan 2009 21:29:40 +0200
Message-ID: <1231961380.25524.0.camel@lb-tlvb-eliezer>
References: <1231951375.11301.126.camel@lb-tlvb-eliezer>
 <1231952234.3010.24.camel@achroite>
 <1231954948.11301.158.camel@lb-tlvb-eliezer>
 <1231956021.3010.35.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1978 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755353AbZANTat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 14:30:49 -0500
In-Reply-To: <1231956021.3010.35.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-14 at 10:00 -0800, Ben Hutchings wrote:
> On Wed, 2009-01-14 at 19:42 +0200, Eilon Greenstein wrote:
> > On Wed, 2009-01-14 at 08:57 -0800, Ben Hutchings wrote:
> > > On Wed, 2009-01-14 at 18:42 +0200, Eilon Greenstein wrote:
> > > > When TPA (HW GRO) is used, the GSO_TYPE should be set
> > > [...]
> > > 
> > > No it shouldn't.  That is for the output path only.
> > > 
> > 
> > Right - but it was an issue with forwarding
> 
> You can't use LRO together with forwarding/bridging unless you replicate
> what Herbert Xu has done to allow reconstruction of the original frames.
> Setting gso_type is a hack which you may or may not get away with,
> depending on the output device's capabilities.
> 
This is far from bullet proof solution, but IMHO it is better set then
not  this way, you stand a chance (depending on the output device
capabilities)

Eilon


