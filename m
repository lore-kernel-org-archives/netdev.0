From: Anton Blanchard <anton@samba.org>
Subject: Re: e1000 performance hack for ppc64 (Power4)
Date: Sat, 14 Jun 2003 10:03:42 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030614000342.GE32097@krispykreme>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107D93A@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, haveblue@us.ibm.com,
   hdierks@us.ibm.com, dwg@au1.ibm.com, linux-kernel@vger.kernel.org,
   milliner@us.ibm.com, ricardoz@us.ibm.com, twichell@us.ibm.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
Content-Disposition: inline
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010107D93A@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
> I thought the answer was no, so I double checked with a couple of
> hardware guys, and the answer is still no.

Hi Scott,

Thats a pity, the e100 docs on sourceforge show it can do what we want,
it would be nice if e1000 had this feature too :)

4.2.2 Read Align

The Read Align feature is aimed to enhance performance in cache line
oriented systems. Starting a PCI transaction in these systems on a
non-cache line aligned address may result in low  performance. To solve
this performance problem, the controller can be configured to terminate
Transmit DMA cycles on a cache line boundary, and start the next
transaction on a cache line aligned address. This  feature is enabled
when the Read Align Enable bit is set in device Configure command
(Section 6.4.2.3, "Configure (010b)").

If this bit is set, the device operates as follows:

* When the device is close to running out of resources on the Transmit
* DMA (in other words, the Transmit FIFO is almost full), it attempts to
* terminate the read transaction on the nearest cache line boundary when 
* possible.

* When the arbitration counters feature is enabled (maximum Transmit DMA
* byte count value is set in configuration space), the device switches
* to other pending DMAs on cache line boundary only.
