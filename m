From: Jeff Garzik <jgarzik@pobox.com>
Subject: Best way to hook incoming eth pkts?
Date: Wed, 20 Aug 2003 11:47:27 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820154727.GB9119@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

All,

netconsole, netdump, and ATA-over-ethernet (and others?) all have a need
to directly send and receive ethernet packets from inside the kernel.

The sending part is easy and obvious.  The receive part isn't.

Essentially, all the things mentioned above need some way to listen
for incoming ethernet packets.  ATA-over-ethernet has its own
IANA-registered ethernet type, but netconsole and netdump are using
IP/UDP instead of a custom ethernet protocol.

So, two questions for the gurus of the crowd ;-)

1) What is the best way for an in-kernel piece of software to 
receive ethernet packets that are intended for it?

2) Possibly related to #1, is it a good or bad idea to consider sending
netconsole/netdump directly over ethernet, eschewing the IP/UDP/syslog
stuff?

Comments and insight requested.

	Jeff
