From: Kevin E <kevin360@yahoo.com>
Subject: Re: Marvell 88E8056 gigabit ethernet controller
Date: Sat, 18 Aug 2007 06:59:08 -0700 (PDT)
Message-ID: <283388.84897.qm@web38905.mail.mud.yahoo.com>
References: <20070818121714.GA28247@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web38905.mail.mud.yahoo.com ([209.191.125.111]:29470 "HELO
	web38905.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751659AbXHRN7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Aug 2007 09:59:09 -0400
In-Reply-To: <20070818121714.GA28247@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--- Willy Tarreau <w@1wt.eu> wrote:

> OK, in this trace, both controllers are on the same
> bus. The broken
> one has 'Capabilities: [100] Advanced Error
> Reporting' the other
> does not have, and the bridge to this bus has two
> more capabilities :
> 'Capabilities: [100] Virtual Channel' and
> 'Capabilities: [180] Unknown (5)'.
> 
> I don't know whether it can jutify a different
> behaviour. Also, maybe this
> is caused by a minuscule difference in the BIOS
> setup ?

I just checked the BIOS' between the two machines and
there was one slight difference.  Working machine I
had serial port turned off and the parallel port setup
differently, so I made changes to the broken machines
BIOS so they are identical.  After making the change I
checked 'lspci -vvv' on the broken one and it's the
same output as before.  

I tested the Marvell interface to see if it made any
difference and the line died after about a second of
transfering data.  dmesg reported this:

sky2 eth1: enabling interface
sky2 eth1: ram buffer 0K
sky2 eth1: Link is up at 100 Mbps, full duplex, flow
control both
sky2 0000:04:00.0: error interrupt status=0x80000000
sky2 eth1: hw error interrupt status 0x8
sky2 eth1: MAC parity error
sky2 0000:04:00.0: error interrupt status=0x80000000
sky2 eth1: hw error interrupt status 0x8
sky2 eth1: MAC parity error
sky2 eth1: disabling interface


Kevin


       
____________________________________________________________________________________Ready for the edge of your seat? 
Check out tonight's top picks on Yahoo! TV. 
http://tv.yahoo.com/
