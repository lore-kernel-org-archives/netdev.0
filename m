From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: pktgen problem (skb refcount) in 2.6.12-rc1
Date: Sun, 3 Apr 2005 21:18:30 +0200
Message-ID: <16976.16774.728707.368646@robur.slu.se>
References: <20050402191132.GF1890@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20050402191132.GF1890@sunbeam.de.gnumonks.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Harald Welte writes:

 > I've tried to get pktgen running on 2.6.12-rc1 (dual-opteron system, two
 > dual e1000 boards).  

 > I've tried to track the problem down, and I've confirmed that skb->users
 > never goes down to 1 but instead stays at '2'.

 > The same system with the same pktgen script works fine with 2.6.11.6.
 > 
 > I'm reporting this since it seems like it sounds like we have a skb
 > usage count leak somewhere :(

 Hello!

 Sounds like a diff could give some clues. pktgen, e1000 and TX-path should 
 be interesting as ev. changes in kernel config.

					--ro
