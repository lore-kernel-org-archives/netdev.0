From: Donald Becker <becker@scyld.com>
Subject: Re: 3C905 + options=0x8
Date: Mon, 20 Oct 2003 11:37:54 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310201130220.3313-100000@training.scyld.com>
References: <Sea2-DAV19xSl5CjBaX00005d53@hotmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marco Berizzi <pupilla@hotmail.com>
In-Reply-To: <Sea2-DAV19xSl5CjBaX00005d53@hotmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Oct 2003, Marco Berizzi wrote:

> I have found a strange 3C905 behaviour on linux 2.4.22 (same behaviuor
> with 2.4.19 and 2.6.0-test7).
> When the linux box load the module with /etc/modules.conf containing:
> options 3c59x options=0x8,0x8

Baseline: what do you expect this option setting to do when used with
the 3c905_ (no suffix)?

Note that the 3c905 has an external MII transceiver (trasceiver type 6),
while the 3c905B and 3c905C have on-chip transceivers (transceiver type 8). 

> the 3C905 NICs don't receive/send packet. 3C905B NIC is working good.

I would say that the driver is working as you directed it to.

You should not set driver options unless you have a non-standard
configuration.  Setting driver options "just to make sure" is a common
source of problems.

I suspect that just removing the module options will restore correct
operation.

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
914 Bay Ridge Road, Suite 220		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
