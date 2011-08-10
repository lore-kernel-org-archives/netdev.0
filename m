From: Simon Farnsworth <simon@farnz.org.uk>
Subject: Re: Use of 802.3ad bonding for increasing link throughput
Date: Wed, 10 Aug 2011 14:50:40 +0100
Message-ID: <j1u2bg$3po$1@dough.gmane.org>
References: <4E427499.8060108@cyconix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:33097 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750768Ab1HJNuy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2011 09:50:54 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Qr9BN-0001a7-Jl
	for netdev@vger.kernel.org; Wed, 10 Aug 2011 15:50:53 +0200
Received: from 110.100.155.90.in-addr.arpa ([90.155.100.110])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2011 15:50:53 +0200
Received: from simon by 110.100.155.90.in-addr.arpa with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2011 15:50:53 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Brown wrote:

> [couldn't thread with '802.3ad bonding brain damaged', as I've just
> signed up]
> 
> So, under what circumstances would a user actually use 802.3ad mode to
> "increase" link throughput, rather than just for redundancy? Are there
> any circumstances in which a single file, for example, could be
> transferred at multiple-NIC speed? The 3 hashing options are:
> 
As an example, from my server room here; I have an install server (TFTP, FTP 
and HTTP) connected by a 2x1G LACP bond to the switch. When I have multiple 
clients installing simultaneously, the layer2 hash distributes the load 
nicely across both NICs - I can reach saturation on both NICs together.

If I had routers between my clients and the install server, I'd need 
layer2+3 hashing to spread the clients over the links, but I'd still be able 
to push over a gigabit per second to the clients, despite being limited to 
1GBit/s to each individual client by the packet distribution.

I'm sure that you can think of lots of other situations in which you have 
multiple conversations sharing a link - those are the situations that gain 
speed from 802.3ad.
-- 
Simon Farnsworth

