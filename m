From: "Alan Shih" <alan@storlinksemi.com>
Subject: RE: TOE brain dump
Date: Sat, 2 Aug 2003 23:22:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <ODEIIOAOPGGCDIKEOPILKEKKDAAA.alan@storlinksemi.com>
References: <3F2C891B.7080004@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Nivedita Singhvi" <niv@us.ibm.com>,
   "Werner Almesberger" <werner@almesberger.net>, <netdev@oss.sgi.com>,
   <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ben Greear" <greearb@candelatech.com>, "Jeff Garzik" <jgarzik@pobox.com>
In-Reply-To: <3F2C891B.7080004@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A DMA xfer that fills the NIC pipe with IDE source. That's not very hard...
need a lot of bufferring/FIFO though.  May require large modification to the
file serving applications?

Alan

-----Original Message-----
From: linux-kernel-owner@vger.kernel.org
[mailto:linux-kernel-owner@vger.kernel.org]On Behalf Of Ben Greear
Sent: Saturday, August 02, 2003 9:02 PM
To: Jeff Garzik
Cc: Nivedita Singhvi; Werner Almesberger; netdev@oss.sgi.com;
linux-kernel@vger.kernel.org
Subject: Re: TOE brain dump


Jeff Garzik wrote:

> So, fix the other end of the pipeline too, otherwise this fast network
> stuff is flashly but pointless.  If you want to serve up data from disk,
> then start creating PCI cards that have both Serial ATA and ethernet
> connectors on them :)  Cut out the middleman of the host CPU and host

I for one would love to see something like this, and not just Serial ATA..
but maybe 8x Serial ATA and RAID :)

Ben


--
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


