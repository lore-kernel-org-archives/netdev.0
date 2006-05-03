From: "Leonid Grossman" <Leonid.Grossman@neterion.com>
Subject: RE: VJ Channel API - driver level (PATCH)
Date: Wed, 3 May 2006 09:56:18 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7766E23D@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <alex@neterion.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:38024 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1030218AbWECN4K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 09:56:10 -0400
Received: from owa.neterion.com (owa.neterion.com [72.1.205.136])
	by barracuda.mail.s2io.com (Spam Firewall) with ESMTP id EAD702001B01
	for <netdev@vger.kernel.org>; Wed,  3 May 2006 09:56:08 -0400 (EDT)
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>, <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: netdev-owner@vger.kernel.org 
> [mailto:netdev-owner@vger.kernel.org] On Behalf Of David S. Miller
> Sent: Tuesday, May 02, 2006 11:48 PM
> To: shemminger@osdl.org
> Cc: alex@neterion.com; netdev@vger.kernel.org
> Subject: Re: VJ Channel API - driver level (PATCH)
> 
> 
> I don't think we should be defining driver APIs when we 
> haven't even figured out how the core of it would even work yet.
> 
> A key part of this is the netfilter bits, that will require 
> non-trivial flow identification, a hash will simply not be 
> enough, and it will not be allowed to not support the 
> netfilter bits properly since everyone will have netfilter 
> enabled in one way or another.

Hi Dave,

Do you have suggestions on potential hardware assists/offloads for
netfilter?

I suppose some of it can be worthwhile, although in general may be too
complex to implement - especially above 1 Gig. 

I'd expect high end NIC ASICs to implement rx steering based upon some
sort of hash (for load balancing), as well as explicit "1:1" steering
between a sw channel and a hw channel. Both options for channel
configuration are present in the driver interface.
If netfilter assists can be done in hardware, I agree the driver
interface will need to add support for these - otherwise, netfilter
processing will stay above the driver.


> -
> To unsubscribe from this list: send the line "unsubscribe 
> netdev" in the body of a message to majordomo@vger.kernel.org 
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
