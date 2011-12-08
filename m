From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Latency difference between fifo and pfifo_fast
Date: Wed, 07 Dec 2011 22:20:57 -0500 (EST)
Message-ID: <2f3f4d56-405e-4369-9a8d-b4940ea5d240@jasiiieee>
References: <20111207154907.462846cb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Dave Taht <dave.taht@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:56794 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756542Ab1LHCUk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 21:20:40 -0500
In-Reply-To: <20111207154907.462846cb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "Stephen Hemminger" <shemminger@vyatta.com>
> To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
> Cc: "David Laight" <David.Laight@ACULAB.COM>, netdev@vger.kernel.org, "Rick Jones" <rick.jones2@hp.com>, "Dave Taht"
> <dave.taht@gmail.com>, "Eric Dumazet" <eric.dumazet@gmail.com>
> Sent: Wednesday, December 7, 2011 6:49:07 PM
> Subject: Re: Latency difference between fifo and pfifo_fast
> 
> =
> > > Is this a shared network? TOS won't matter if it is only your
> > > traffic.
> > > 
> > > There are number of route metrics that you can tweak to that can
> > > reduce TCP slow
> > > start effects, like increasing the initial cwnd, etc.
> > > 
> > It is a private network dedicated only to SAN traffic - a couple of
> > SAN devices and some virtualization hosts - John
> 
> Therefore unless your switch is shared, playing with queueing and TOS
> won't help reduce absolute latency.
> You maybe able to prioritize one host or SAN over another though.
> 
That's why I was wondering if we should switch to fifo from pfifo_fast since there is no prioritization of one host or SAN over another.  Thanks - John
