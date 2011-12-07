From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Latency difference between fifo and pfifo_fast
Date: Wed, 7 Dec 2011 15:49:07 -0800
Message-ID: <20111207154907.462846cb@nehalam.linuxnetplumber.net>
References: <20111207152709.37b5798d@nehalam.linuxnetplumber.net>
	<88e4825e-4efe-4163-bb24-299a20aab66d@jasiiieee>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Dave Taht <dave.taht@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34450 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751470Ab1LGXtK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 18:49:10 -0500
In-Reply-To: <88e4825e-4efe-4163-bb24-299a20aab66d@jasiiieee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=
> > Is this a shared network? TOS won't matter if it is only your
> > traffic.
> > 
> > There are number of route metrics that you can tweak to that can
> > reduce TCP slow
> > start effects, like increasing the initial cwnd, etc.
> > 
> It is a private network dedicated only to SAN traffic - a couple of SAN devices and some virtualization hosts - John

Therefore unless your switch is shared, playing with queueing and TOS
won't help reduce absolute latency.
You maybe able to prioritize one host or SAN over another though.
