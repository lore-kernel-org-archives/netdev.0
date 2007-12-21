From: "James Nichols" <jamesnichols3@gmail.com>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Fri, 21 Dec 2007 08:57:25 -0500
Message-ID: <83a51e120712210557s2f43c238i5139ae74753a0f17@mail.gmail.com>
References: <83a51e120712141239u52d2dd68p1b6ee7ed08f2cecf@mail.gmail.com>
	 <83a51e120712181144l65633b32r72cc369f9d012f47@mail.gmail.com>
	 <47682F8C.20205@cosmosbay.com>
	 <83a51e120712190853q33d9c7c1t4a46380665b7538b@mail.gmail.com>
	 <47694FCC.1020507@cosmosbay.com>
	 <83a51e120712190943m3bf0e2e4v2ea6b660142e9a5a@mail.gmail.com>
	 <Pine.LNX.4.64.0712191857270.12329@fbirervta.pbzchgretzou.qr>
	 <1198161695.6154.47.camel@andromache>
	 <83a51e120712200837p9e3d1a4g15b5f4763597073e@mail.gmail.com>
	 <1198212686.5904.17.camel@andromache>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jan Engelhardt" <jengelh@computergmbh.de>,
	"Eric Dumazet" <dada1@cosmosbay.com>, linux-kernel@vger.kernel.org,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Glen Turner" <gdt@gdt.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:57562 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbXLUN51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 08:57:27 -0500
Received: by fg-out-1718.google.com with SMTP id e21so167228fga.17
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 05:57:25 -0800 (PST)
In-Reply-To: <1198212686.5904.17.camel@andromache>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Huh?  Do you mean a PIX blade in a Cisco switch-router chassis? It
> would be very useful if you could be less vague about the
> equipment in use.

Right it's a PIX blade in Cisco chassis.  The PIX is running ASA version 7.0(6)



> That depends more on your customers' networking attributes
> then you are sharing or perhaps even know.  Perhaps your customer
> base is very Window-skewed and you simply aren't seeing any Sack
> Permitted negotiations for the first 37.999 hours. Or
> perhaps you've had a network glitch, and all of your
> connections have done a Selective Ack, which the firewall
> has trashed, leaving all the connections in a wacko state,
> not just a few which you haven't noticed.

I definitely see SACKs over the course of the 38 hours.  I don't have
any Windows hosts, they are all running Linux except for a very small
number that run a proprietary OS and webserver.  If the firewall were
to get trashed and hose the currently active connections, I would
expect that newly initiated connections would work.


> The actual failure mode needs a packet trace to determine,
> but you should be able to do this yourself (or ask your
> local network engineering staff).
>
> If your firewall is trashing the Sack field, then it needs
> to be fixed.  Time to raise a case with the Cisco TAC and
> ask them directly if your PIX version has bug CSCse14419.
> You can't expect Sack to work when it's being fed trash,
> so it is important to make sure that is not happening.

I've pinged our dude that handles the PIX stuff to see about getting
an upgrade to 7.0(7).  I should be able to get a packet trace, but it
may take some time.  At this point I'm getting a lot of resistance and
people here telling me to just turn SACK off and not worry about what
is causing this issue, but I'd really like to get to the bottom of it.
