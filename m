From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 23:31:10 +0100
Message-ID: <1447972270.3061531.444784113.21E95CAA@webmail.messagingengine.com>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
 <20151119.005318.838757439536205791.davem@davemloft.net>
 <CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
 <20151119.104811.1447518072450380661.davem@davemloft.net>
 <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S363gYA37GnEuArp+PKVjFdLchB_66zuLF5kJnSFKF4t6Q@mail.gmail.com>
 <1447969264.22599.253.camel@edumazet-glaptop2.roam.corp.google.com>
 <1447969982.3054314.444761185.363F62E7@webmail.messagingengine.com>
 <1447970641.22599.261.camel@edumazet-glaptop2.roam.corp.google.com>
 <1447970956.3057330.444776169.61AEFA6C@webmail.messagingengine.com>
 <1447971335.22599.268.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	zenczykowski <zenczykowski@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:36726 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934679AbbKSWbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 17:31:11 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id D2D932097F
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 17:31:10 -0500 (EST)
In-Reply-To: <1447971335.22599.268.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, Nov 19, 2015, at 23:15, Eric Dumazet wrote:
> On Thu, 2015-11-19 at 23:09 +0100, Hannes Frederic Sowa wrote:
> 
> > My point is the "eventually" and the very much increased latency until
> > the kernel learns about new better source addresses it has available. I
> > would monitor link quality over time and decide source address based on
> > this on the sending side.
> 
> We are here speaking of code running in a browser (like Chrome speaking
> to Google servers). Written in java script or whatever language du jour.
> 
> It has no business of managing routes, or interfaces.

I thought it would be necessary to support multipathing in QUIC?

Interesting and thanks,
Hannes
