From: Christoph Hellwig <hch@lst.de>
Subject: [wbrown338@netscape.net: 2.6 kernels not allowing eth0 connection]
Date: Sat, 14 Aug 2004 20:51:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814185129.GA28942@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wbrown338@netscape.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

----- Forwarded message from William Brown <wbrown338@netscape.net> -----

Date: Sat, 14 Aug 2004 11:13:54 -0400
From: wbrown338@netscape.net (William Brown)
Subject: 2.6 kernels not allowing eth0 connection
To: debian-kernel@lists.debian.org
X-Mailer: Atlas Mailer 2.0

Greetings:

I have tried submitting a bug # #254962 through the debian bug reporting system but I don't think it made it to anybody. I was told by an old maintainer of the 2.6 kernel (Herbert Xu) to submitt the info here.  The following is output from some system logs.  Basically the eth0 connection won't work on any of the 2.6 kernel builds.  It does work with the 2.4 kerneles:

>From syslog:

Aug 13 12:51:41 localhost kernel: irda_init()
Aug 13 12:51:41 localhost kernel: NET: Registered protocol family 23
Aug 13 12:51:41 localhost kernel: 8139too Fast Ethernet driver 0.9.27
Aug 13 12:51:41 localhost kernel: eth0: RealTek RTL8139 at 0xc000, 00:0d:88:3b:a5:73, IRQ 10
Aug 13 12:51:41 localhost kernel: eth0:  Identified 8139 chip type 'RTL-8100B/8139D'
Aug 13 12:51:41 localhost kernel: via-rhine.c:v1.10-LK1.1.20-2.6 May-23-2004 Written by Donald Becker
Aug 13 12:51:41 localhost kernel: eth1: VIA VT6102 Rhine-II at 0xec00, 00:d0:68:01:57:18, IRQ 11.
Aug 13 12:51:41 localhost kernel: eth1: MII PHY found at address 1, status 0x7849 advertising 05e1 Link 0000.
...
Aug 13 12:51:41 localhost kernel: NET: Registered protocol family 17
Aug 13 12:51:41 localhost kernel: eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
Aug 13 12:51:41 localhost kernel: NETDEV WATCHDOG: eth0: transmit timed out
Aug 13 12:51:41 localhost kernel: eth0: Transmit timeout, status 0c 0005 c07f media 10.
Aug 13 12:51:41 localhost kernel: eth0: Tx queue start entry 4  dirty entry 0.
Aug 13 12:51:41 localhost kernel: eth0:  Tx descriptor 0 is 0008a24e. (queue head)
Aug 13 12:51:41 localhost kernel: eth0:  Tx descriptor 1 is 0008a24e.
Aug 13 12:51:41 localhost kernel: eth0:  Tx descriptor 2 is 0008a24e.
Aug 13 12:51:41 localhost kernel: eth0:  Tx descriptor 3 is 0008a24e.
Aug 13 12:51:41 localhost kernel: eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
Aug 13 12:51:41 localhost kernel: NETDEV WATCHDOG: eth0: transmit timed out
Aug 13 12:51:41 localhost kernel: eth0: Transmit timeout, status 0c 0005 c07f media 10.


from debug:

Aug 13 12:51:41 localhost kernel: eth0:  Identified 8139 chip type 'RTL-8100B/8139D'
Aug 13 12:51:41 localhost kernel: eth0: Transmit timeout, status 0c 0005 c07f media 10.
Aug 13 12:51:41 localhost kernel: eth0: Tx queue start entry 4  dirty entry 0.
Aug 13 12:51:41 localhost kernel: eth0:  Tx descriptor 0 is 0008a24e. (queue head)
Aug 13 12:51:41 localhost kernel: eth0:  Tx descriptor 1 is 0008a24e.
Aug 13 12:51:41 localhost kernel: eth0:  Tx descriptor 2 is 0008a24e.
Aug 13 12:51:41 localhost kernel: eth0:  Tx descriptor 3 is 0008a24e.
Aug 13 12:51:41 localhost kernel: eth0: Transmit timeout, status 0c 0005 c07f media 10.
Aug 13 12:51:41 localhost kernel: eth0: Tx queue start entry 4  dirty entry 0.
Aug 13 12:51:41 localhost kernel: eth0:  Tx descriptor 0 is 0008a24e. (queue head)
Aug 13 12:51:41 localhost kernel: eth0:  Tx descriptor 1 is 0008a24e.
Aug 13 12:51:41 localhost kernel: eth0:  Tx descriptor 2 is 0008a24e.
Aug 13 12:51:41 localhost kernel: eth0:  Tx descriptor 3 is 0008a24e.


>From dmesg:

NET: Registered protocol family 17
eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
NETDEV WATCHDOG: eth0: transmit timed out
eth0: Transmit timeout, status 0c 0005 c07f media 10.
eth0: Tx queue start entry 4  dirty entry 0.
eth0:  Tx descriptor 0 is 0008a24e. (queue head)
eth0:  Tx descriptor 1 is 0008a24e.
eth0:  Tx descriptor 2 is 0008a24e.
eth0:  Tx descriptor 3 is 0008a24e.


Does this look familiar to anyone?

Thanks.
Bill. 


__________________________________________________________________
Switch to Netscape Internet Service.
As low as $9.95 a month -- Sign up today at http://isp.netscape.com/register

Netscape. Just the Net You Need.

New! Netscape Toolbar for Internet Explorer
Search from anywhere on the Web and block those annoying pop-ups.
Download now at http://channels.netscape.com/ns/search/install.jsp


-- 
To UNSUBSCRIBE, email to debian-kernel-REQUEST@lists.debian.org
with a subject of "unsubscribe". Trouble? Contact listmaster@lists.debian.org

----- End forwarded message -----
