From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: pktgen performance numbers
Date: Sun, 14 Nov 2004 16:46:53 +0100
Message-ID: <20041114154653.GA3857@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

On an intel 7505-based board with onboard e1000 and dual 2.4ghz xeon
processors running 2.6.10-rc1, I can send ~600kpps 60byte packets using
pktgen.  I'm using only one CPU, the IRQ tied to that CPU, etc.  On a
single P4 3.0GHz with a 32/33 e1000 PCI card, I get ~450kpps, also on
2.6.10-rc1.

Robert Olsson's pktgen paper* talks about 870kpps using an e1000 in a
P3 733, and 2.4Mpps on a dual 1.6GHz opteron, but I've been totally
unable to reproduce anything like this at all.

Any ideas for stuff I should try?


thanks,
Lennert

* ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/pktgen_paper.pdf
