From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: set congestion default through Kconfig
Date: Tue, 19 Sep 2006 14:35:35 +0200
Message-ID: <20060919123534.GC7000@c3po.0xdef.net>
References: <20060918095936.GA6161@outpost.ds9a.nl> <20060918195224.GA26585@outpost.ds9a.nl> <20060918214104.3824a2e2@localhost.localdomain> <200609191203.51045.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Stephen Hemminger <shemminger@osdl.org>,
	bert hubert <bert.hubert@netherlabs.nl>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from c3po.0xdef.net ([217.172.181.57]:44815 "EHLO c3po.0xdef.net")
	by vger.kernel.org with ESMTP id S1030222AbWISMfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 08:35:36 -0400
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <200609191203.51045.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Andi Kleen | 2006-09-19 12:03:51 [+0200]:

>How about a single auto selection heuristic: e.g. check the handshake latencies 
>and if they are too long switch from reno to the newer one deemed most
>stable?

Thats absolute no practicable solution to discover the 'right' algorithm.
The latenzy is only one piece in the puzzle the determine the optimal
congestion control algorithm and completely inadequate. You must also discover
the bandwith and other factors to make a decision. And this is nearly
impossible and object of actual research.

Through due to the heterogeneity of the net it is often not possible the
select the right one. To select a "general purpose algorithm" here is the
better choice.

BTW: BIC is sometimes to aggressive in comparison to standard tcp behaviour
(e.g. in short RTT environments) - this is an known issue. Why not cubic as the
default one?

>-Andi

HGN



-- 
"You need the computing power of a Pentium, 16 MB RAM and 1 GB Harddisk
to run Win95. It took the computing power of 3 Commodore 64
to fly to the Moon. Something is wrong here, and it wasn't the Apollo."

