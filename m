From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Fri, 24 Aug 2007 11:51:10 -0500
Message-ID: <20070824165110.GH4282@austin.ibm.com>
References: <200708241559.17055.ossthema@de.ibm.com> <20070824153703.GN5592@sgi.com> <200708241747.16592.ossthema@de.ibm.com> <20070824085203.42f4305c@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, Marcus@ozlabs.org,
	Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	linux-ppc <linuxppc-dev@ozlabs.org>, akepner@sgi.com,
	Eder <meder@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:32908 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759693AbXHXQvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 12:51:13 -0400
Content-Disposition: inline
In-Reply-To: <20070824085203.42f4305c@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 24, 2007 at 08:52:03AM -0700, Stephen Hemminger wrote:
> 
> You need hardware support for deferred interrupts. Most devices have it (e1000, sky2, tg3)
> and it interacts well with NAPI. It is not a generic thing you want done by the stack,
> you want the hardware to hold off interrupts until X packets or Y usecs have expired.

Just to be clear, in the previous email I posted on this thread, I
described a worst-case network ping-pong test case (send a packet, wait
for reply), and found out that a deffered interrupt scheme just damaged
the performance of the test case.  Since the folks who came up with the
test case were adamant, I turned off the defferred interrupts.  
While defferred interrupts are an "obvious" solution, I decided that 
they weren't a good solution. (And I have no other solution to offer).

--linas

