From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Subject: Re: Issue Report: forcedeth v0.23, irq with unknown events
Date: Sun, 07 Mar 2004 14:08:12 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <404B1EBC.6030901@gmx.net>
References: <1078624409.404a80995e634@webmail.colorado.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Adam.Torgerson@colorado.edu
In-Reply-To: <1078624409.404a80995e634@webmail.colorado.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adam.Torgerson@colorado.edu wrote:
> Hello, I'm getting tons of these kernel messages:
> 
> "eth0: received irq with unknown events 0x1. Please report"

This event is no longer unknown. It is a RX error and you are not the only
one encountering it. I have a patch which will speed up the network a bit
and remove the message, but it seems you have serious connection problems.

> on an Abit NF7 (nforce2 Ultra400 + MCP-T is what the box says), so I
> figured I better report it. The driver works, but is quite slow (only
> 256kB/s on a local 100Mbit network). lspci shows the device as:
> 
> 00:04.0 Ethernet controller: nVidia Corporation nForce2 Ethernet
> Controller (rev a1)
> 
> Currently using 2.6.4-rc1-mm2. Let me know if I can provide any more
> information (please CC me as I'm not on any lists).

I will send you an updated version of the driver soon for testing.

Rregards,
Carl-Daniel
-- 
http://www.hailfinger.org/
