From: Sven Schuster <schuster.sven@gmx.de>
Subject: Linux <---> Unixware slow networking with e100
Date: Thu, 06 Nov 2003 08:31:33 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3FA9F8D5.9020601@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello everybody,

we have a little problem here with networking between linux
(redhat AS 2.1 2.4.9-e.27smp) and unixware 7.1.1 . The network
card is a Intel 82557 Ethernet Pro 100 (lspci output) on a 100 mbit
network. When doing data transfers between two linux machines,
everything works fine, we have transfer rates of about 10 MB/s.
But when _receiving_ data from one of the unixware machines, we
just get a few kB/s, max. about 100 kB/s. When _sending_ data to
a unixware machine, the transfer rate is fine too. Are there any
known issues between linux and unixware (except the SCO thing
;-) ) ??
At first we used the eepro100 driver, but this gave us poor
performance on receive with every other machine, whether it was
unixware or linux.

Another thing on that machine is, that there's a Intel 82544GC
copper gigabit card in it. When using this one with the e1000 driver,
it also gave us bad performance on receive (also just around max.
100 kB/s). Maxbe there are some options for module loading for
the e1000 driver??

Thanks in advance for any tips!!!



Sven


