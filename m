From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [0/3] mc_filter on big-endian arch
Date: Thu, 10 Jun 2004 15:47:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF594AC2E9.2896A248-ON88256EAF.007CCB5F-88256EAF.007D1A3E@us.ibm.com>
References: <1086874679.23004.17.camel@dillow.idleaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
        Netdev <netdev@oss.sgi.com>, Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <1086874679.23004.17.camel@dillow.idleaire.com>
To: Dave Dillow <dave@thedillows.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Roger suggested that I bring to "netdev" the comment I made to him
in private e-mail about his FAQ, so here it is:

if you add multicast addresses via "ip maddr" in the way described,
it won't work for some hardware configurations. In particular, if you have
an Ethernet switch that does IGMP snooping, the switch won't replicate
multicast packets on ports that haven't had IGMP reports for the multicast
address you're testing. In that case, having it in the hardware MAF 
doesn't
help, and you'll need to do the IP-level join to get them delivered.

                                        +-DLS
