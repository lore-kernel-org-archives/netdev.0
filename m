From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: pktgen performance numbers
Date: Sun, 14 Nov 2004 17:32:50 +0100
Message-ID: <16791.34994.647288.940473@robur.slu.se>
References: <20041114154653.GA3857@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041114154653.GA3857@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 Hello!

Lennert Buytenhek writes:
 > Hi all,
 > 
 > On an intel 7505-based board with onboard e1000 and dual 2.4ghz xeon
 > processors running 2.6.10-rc1, I can send ~600kpps 60byte packets using
 > pktgen.  I'm using only one CPU, the IRQ tied to that CPU, etc.  On a
 > single P4 3.0GHz with a 32/33 e1000 PCI card, I get ~450kpps, also on
 > 2.6.10-rc1.

 PCI-bus limitations probably. Lots of transactions per packet. I was trying 
 TX performance with small packets (64 byte) at w. different bus speeds it 
 seems like even at PCI-X 133 MHz this is a limit. 

 Also PCI-brigades decreases TX performance according to Grant Graundler
 this probably to the extra delay added.

 Grant Grundler gave a talk on OLS 2004 covering many aspects of this.

 > Robert Olsson's pktgen paper* talks about 870kpps using an e1000 in a
 > P3 733, and 2.4Mpps on a dual 1.6GHz opteron, but I've been totally
 > unable to reproduce anything like this at all.

 The 2.4 Mpps mentioned is aggregated TX performance from an DUAL Opteron 
 at 1.6 GHz using several e1000's.

 The the best single stream (from one NIC) wee see is about 870 kpps.
 (ServerWorks chipset) So the BSD claims to route 1 Mpps puzzles me a bit 
 as we cannot even send.

 Again it would be interesting to see some numbers from decent PCI-connected
 10 GIGE cards.

 Cheers.
						--ro
