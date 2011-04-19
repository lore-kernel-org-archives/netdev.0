From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: DSCP values in TCP handshake
Date: Tue, 19 Apr 2011 19:38:44 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1104191934270.13186@uplift.swm.pp.se>
References: <loom.20110418T154445-102@post.gmane.org> <1303135512.3137.335.camel@edumazet-laptop> <20110418083827.05dd2d43@nehalam> <alpine.DEB.2.00.1104181750150.14027@uplift.swm.pp.se> <4DAC8A8A.1010401@cox.net> <alpine.DEB.2.00.1104182115291.14027@uplift.swm.pp.se>
 <20110418144908.55967b06@nehalam> <alpine.DEB.2.00.1104190547300.14027@uplift.swm.pp.se> <20110418211637.57f1cfb8@nehalam> <alpine.DEB.2.00.1104190620070.14027@uplift.swm.pp.se> <BANLkTi=fDdoF=kSfY=9ER4iR3M27L=CLXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Joe Buehler <aspam@cox.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Matt Mathis <mattmathis@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:35565 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753441Ab1DSRip (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 13:38:45 -0400
In-Reply-To: <BANLkTi=fDdoF=kSfY=9ER4iR3M27L=CLXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Apr 2011, Matt Mathis wrote:

> Please do.  This missing spec is one of the things that makes Less than 
> Best Effort (aka scavenger service) unusable.  Only the client knows if 
> they are fetching data in the background.  The server doesn't care.

I emailed with Fred Baker and the below text seems to be where it ended 
regarding reflexive marking of packets. If someone wants this changed, 
they need to bring it up with the IETF.

<http://www.ietf.org/proceedings/54/220.htm>

"Fred Baker presented draft-ietf-ieprep-packet-marking-policy-00.txt

Van Jacobsen presented a concern for Kathy Nichols, Diffserv co-chair. The 
concern was that the DSCP is intended to identify traffic supported by a 
service, as opposed to traffic of a certain application type. He also 
worried that a specific BCP indicating the facilities used to support such 
services might be misused by regulators to mandate ISP services. 
Specifically, he wanted a statement between the requirements document and 
a document suggesting a specific configuration identifying the fact that 
inter-service-provider signaling as specified in this draft is certainly 
specified but is not commonly implemented.

Christian Huitema and another speaker also commented that while a cookbook 
such as this was an interesting useful document, it didn't seem to 
directly stem from emergency as a context.

Rei Atarashi presented draft-ietf-ieprep-reflexive-dscp-00.txt

Van basically felt that the notion of a default response from the host was 
inappropriate; this is something every network should provide a policy 
for. "

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
