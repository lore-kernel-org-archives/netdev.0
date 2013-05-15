From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Patch iproute2] vxlan: use 8472 as default dst port
Date: Wed, 15 May 2013 14:11:51 -0400
Message-ID: <OF80FDF86D.7A293781-ON85257B6C.0061CCF7-85257B6C.0063F69C@us.ibm.com>
References: <1368616270-5775-1-git-send-email-amwang@redhat.com>	<OFA8084FAB.8443890D-ON85257B6C.003F1FAB-85257B6C.003F65F2@us.ibm.com>
	<20130515095322.275c9b2f@nehalam.linuxnetplumber.net>	<OFF100C7ED.6500FAB3-ON85257B6C.005DCF7C-85257B6C.005F309B@us.ibm.com> <20130515104308.5de3e852@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:54106 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932979Ab3EOSNK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 14:13:10 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 15 May 2013 14:13:09 -0400
In-Reply-To: <20130515104308.5de3e852@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 05/15/2013 01:43:08 PM:

> From: Stephen Hemminger <stephen@networkplumber.org>
> 
> I want all new users to get the IANA port without asking.
> Old users with existing nets have to force the port to the one they 
> were using.

That'd be great -- what we're getting is all new users are getting
a listen port of 8472 and a send port of 4789. So new users who aren't
aware of why will simply see that two *new* installations don't talk
to each other (and never will, using default ports, because the kernel
and ip will need to be compatible with their incompatible selves).

You have to either specify "udp_port=4789" at modprobe or boot, or specify
a port for every fdb entry via "ip" so that the listen and send ports 
match.

I think both of those are worse than using the "wrong" port by default, 
and both
of those are worse than changing the default port for the limited user
set so far.

                                                        +-DLS
