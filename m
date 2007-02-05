From: Ashwin Chaugule <ashwin.chaugule@celunite.com>
Subject: Re: Wireless network card capabilities
Date: Mon, 05 Feb 2007 13:42:27 +0530
Message-ID: <1170663148.4692.2.camel@localhost.localdomain>
References: <45C5B892.3000507@superbug.co.uk>
	 <20070204122721.GA2280@p15091797.pureserver.info>
Reply-To: ashwin.chaugule@celunite.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Courtier-Dutton <James@superbug.co.uk>,
	netdev@vger.kernel.org
To: Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs384.securehostserver.com ([72.22.69.69]:4342 "HELO
	rs384.securehostserver.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751994AbXBEIMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 03:12:32 -0500
In-Reply-To: <20070204122721.GA2280@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-02-04 at 13:27 +0100, Ulrich Kunitz wrote:
> On 07-02-04 10:42 James Courtier-Dutton wrote:
> 
> > Hi,
> > 
> > Can Wireless network cards receive and transmit on two channels at once?
> > I am thinking of implementing a way for a wireless VoIP phone on Linux 
> > being able to hand off from one AP to another without dropping the call.
> > For this to work, the wireless card must be able to chat on two channels 
> > during the handover, so as to not loose any voice packets.
> > 
> > James
> 
> The easiest way to achieve this is to use two wireless adapters.
> I'm not sure, whether there are adapters, which support parallel
> reception on two channels and manage two independent
> associations at the same time. 
> 

Not too sure, but from what I've understood of Channel bonding, maybe
you could bind the 2 wifi ifaces using 2 adapters and linux's channel
bonding modules ?

Ashwin

