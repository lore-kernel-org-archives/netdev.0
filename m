From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: serial port-to-netdevice tap
Date: Wed, 16 Jun 2004 13:55:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3hdtbn2dn.fsf@defiant.pm.waw.pl>
References: <C060DFCD9697A842B3189B458524FDC205D2C9@AIMAIL1.ai.aiinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Eble, Dan" <DanE@aiinet.com>
In-Reply-To: <C060DFCD9697A842B3189B458524FDC205D2C9@AIMAIL1.ai.aiinet.com> (Dan
 Eble's message of "Tue, 15 Jun 2004 11:50:01 -0400")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Eble, Dan" <DanE@aiinet.com> writes:

> A coworker of mine wants an easy way to monitor data transfer and control
> line changes on an serial port.  His first impulse was to create a /proc
> file, but I suggested a netlink socket, or even a raw net device so that he
> can take advantage of libpcap for some pretty powerful filtering.  Does
> anything like this exist already?

With character device? I don't think so. One could use a pseudo
terminal combo, though. Another option is to use two additional ports
with their RX lines connected to both TX and RX lines of the main
port. Depends on requirements.
I use a "data acquisition" card with all the async serial protocol
etc. analysis in (quite simple) software.
A "strace" (if you want to see what a process does) could be a help as
well.
-- 
Krzysztof Halasa, B*FH
