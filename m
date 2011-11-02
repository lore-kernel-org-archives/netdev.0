From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Subnet router anycast for FE80/10 ?
Date: Wed, 2 Nov 2011 10:33:58 -0700
Message-ID: <OFC7C1D462.090FDB12-ON8825793C.005F496E-8825793C.00607E99@us.ibm.com>
References: <4EAF0391.80907@collax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Andreas Hofmeister <andi@collax.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:34024 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755735Ab1KBRet (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 13:34:49 -0400
Received: from /spool/local
	by e3.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 2 Nov 2011 13:34:39 -0400
In-Reply-To: <4EAF0391.80907@collax.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 10/31/2011 01:22:41 PM:

> But then, FE80/10 is not actually supposed to be routed at all and so a 
> router cannot not really be a router for that particular subnet ?
> 
> Or is "FE80::" just supposed to be the anycast equivalent for the "all 
> routers" multicast address ff02::2 ?
> 
> Maybe someone on this list could enlighten me.

I think it's just a matter of not making an exception for LL addresses.
Forwarding is for the interface, not for individual prefixes.
If forwarding is enabled on the interface, anycast addresses for all
its prefixes are added.

It could be used to send to "any router" on a subnet, of course.

                                                        +-DLS
