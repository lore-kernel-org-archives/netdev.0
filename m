From: Julian Anastasov <ja@ssi.bg>
Subject: Re: send-to-self (was Re: routing bug report for 2.4)
Date: Sun, 29 Jun 2003 23:18:50 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306292307130.9328-100000@u.domain.uli>
References: <Pine.LNX.4.44.0306291110070.8466-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <Pine.LNX.4.44.0306291110070.8466-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

	Ben, I have something for comments and testing (compiled
only):

http://www.ssi.bg/~ja/send-to-self-2.4.21-1.diff

The usage should be:
eth0/loop=1
eth1/loop=1
bind to src IP from eth0 and connect to local IP on eth1

Be ready, there can be something totally wrong.

I'm avoiding the arp_filter changes. The setup uses
asymmetric routing so better use arp_filter=0 or other
ARP filtering tools that can restrict our ARP replies 
only via the desired device.

Regards

--
Julian Anastasov <ja@ssi.bg>
