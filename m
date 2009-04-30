From: Mark Smith
	<lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
Subject: Re: [RFC, PATCH 2.6.29.2] Ethernet V2.0 Configuration Testing
 Protocol, revision 20090428
Date: Thu, 30 Apr 2009 20:09:26 +0930
Message-ID: <20090430200926.f1ae5e60.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
References: <20090430065950.529359e3.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
	<20090429.143534.32129577.davem@davemloft.net>
	<20090430190644.4d116984.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
	<20090430.024259.228836764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.adam.net.au ([202.136.110.249]:44882 "EHLO
	smtp3.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbZD3Kja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 06:39:30 -0400
In-Reply-To: <20090430.024259.228836764.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Apr 2009 02:42:59 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Mark Smith <lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
> Date: Thu, 30 Apr 2009 19:06:44 +0930
> 
> > In my opinion, the primary reason why these sorts of testing functions
> > have been put in kernels rather than user space is to ensure ubiquity.
> 
> By this argument we should have a BGP routing daemon in the kernel
> too.
> 

BGP is not for testing basic connectivity. It's for carrying Internet
scale routing information. I work with it daily. What benefit would
there be in making it ubiquitous to all end nodes? I can't see one, and
I've never argued that complex protocols that aren't performance
critical, and that aren't useful on every device should be in the
kernel. I've very specifically *only* argued that every Ethernet
interface would benefit from having an Ethernet specific testing
protocol always being available. The authors of the 1982 Ethernet V2.0
spec thought was valuable so they mandated it, the implementers of
Cisco IOS thought was valuable, as did the Berkely Unix 4.2 and Ultrix
authors, and the IEEE think the functionality is valuable because
they've gone and developed Ethernet OAM protocols. 

Is there any chance you're going to answer what I thought were
legitimate questions? I'd much rather find out why things are the way
they are, or aren't the way they appear, but I also don't want to waste
your's or my time.

> But we don't.
> 
> BTW, your email address is rediculious.
> 

It works, so what's wrong with it? Nobody else has complained about me
using these types of email addresses on public mailing lists. I can
throw it away if I get too much spam, pointing the MX record of the
subdomain to 127.0.0.1 or something similar.
