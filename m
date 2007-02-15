From: Holger Eitzenberger <holger@my-eitzenberger.de>
Subject: Re: sky2 bonding problem, 802.3ad
Date: Thu, 15 Feb 2007 22:09:40 +0100
Message-ID: <87fy97t9ez.fsf@kruemel.my-eitzenberger.de>
References: <871wkruu6p.fsf@kruemel.my-eitzenberger.de>
	<200702152013.l1FKDE22017473@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org,
	sk-drivers@lists.linux-foundation.org, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:56407 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161310AbXBOVJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Feb 2007 16:09:45 -0500
In-Reply-To: <200702152013.l1FKDE22017473@death.nxdomain.ibm.com> (Jay
 Vosburgh's message of "Thu, 15 Feb 2007 12:13:14 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh <fubar@us.ibm.com> writes:

> 	I'm unfamiliar with your particular switch, but usually this
> kind of problem with bonding 802.3ad is in the switch interaction.  The
> switches I have (Cisco) require that 802.3ad mode be explicitly enabled
> on whichever ports it is desired on, so it may be worthwhile to check
> your switch and make sure that it really is configured for 802.3ad on
> the sky2 ports.

I am currently using port 1&2 and port 9&10 for bonding and have
configured all four ports for the same aggregator ID 1, LCAP enabled.
I also switched ports, that is, I changed host1 from using port 1&2 to
use port 9&10 and vice versa.  Note that I also used sk98lin which
worked in my setup also.  Do you still think it is a misconfigured
switch?

> 	If the switch is configured, you may want to also check to see
> if it has counters for LACPDUs sent and received.  If the switch is not
> sending and receiving LACPDUs on the appropriate ports, then it's more
> likely to be a communications problem somewhere (vs. an 802.3ad
> negotiation problem).

I will check tomorrow morning whether I see the LACPDUs in the log and
report.

Any more tests which may be helpfull?

Thanks.  /holger
