From: Brian Haley <brian.haley@hp.com>
Subject: Re: radvd and auto-ipv6 address regression from 2.6.31 to 2.6.34+
Date: Mon, 08 Nov 2010 10:54:12 -0500
Message-ID: <4CD81D24.1040609@hp.com>
References: <4CD47622.5040507@candelatech.com> <4CD48FB4.2050903@candelatech.com> <alpine.DEB.1.10.1011060713290.2639@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:38641 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439Ab0KHPyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 10:54:16 -0500
In-Reply-To: <alpine.DEB.1.10.1011060713290.2639@uplift.swm.pp.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/06/2010 02:17 AM, Mikael Abrahamsson wrote:
> I would not be surprised if the IPv6 stack on Linux would gain IPv6
> addresses using SLAAC from any interface if it sees RAs on it,
> regardless if these are locally generated or not.
> 
> I guess any Linux device running radvd should turn off autoconf on those
> interface that radvd is acting on?
> 
> net.ipv6.conf.veth0.accept_ra=0 should do the trick?

I believe radvd will turn-on IPv6 forwarding on all the interfaces, at
least it does on Debian in /etc/init.d/radvd, which essentially disables
the reception of RA's for address configuration purposes.  I'm curious
what these values are set to, and if something just got missed.

It might be something specific to veth too, not sure how packets are
copied/looped-back on these devices from the stack.

-Brian
