From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [0/3] mc_filter on big-endian arch
Date: Mon, 7 Jun 2004 13:59:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040607115921.GB32569@k3.hellgate.ch>
References: <20040606165322.GA13247@k3.hellgate.ch> <1086575392.4731.9.camel@ori.thedillows.org> <20040607114832.GA32569@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
Content-Disposition: inline
In-Reply-To: <20040607114832.GA32569@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

One thing maybe worth mentioning: If you want to play with different
addresses, remember that IP addresses are in decimal notation, ethernet
in hex. So if you set

target# ip maddr add 01:00:5e:00:00:25 dev eth0

the test would be

tester# ping -r -I eth0 -t 1 -c 2 224.0.0.37

Roger
