From: george anzinger <george@mvista.com>
Subject: Re: Network oops
Date: Mon, 10 Jun 2002 01:11:01 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae1nag$ekb$2@main.gmane.org>
References: <200205202125.BAA03545@sex.inr.ac.ru>
		<3D0390E2.1B80ADEE@mvista.com> <20020609.213224.01016187.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:
> 
> Also we need to know what network driver, if preemption is being
> used (being from mvista I assume you are using preemption, and if
> so make sure you have the preemption networking patches applied).

Uh, are you saying there is a set of network patches?  If
so, where might they be found?  And yes, we are testing
preemption, trying to wring out the "last" bug :)  (Could
you be referring to the patches we are developing?)

The driver (from the system log):
    <4>eepro100.c:v1.09j-t 9/29/99 Donald Becker
http://cesdis.gsfc.nasa.gov/linux/drivers/eepro100.html
    <4>eepro100.c: $Revision: 1.36 $ 2000/11/17 Modified by
Andrey V. Savochkin <saw@saw.sw.com.sg> and others
    <6>eth0: OEM i82557/i82558 10/100 Ethernet,
00:03:47:BD:60:86, IRQ 21.
    <6>  Board assembly fab600-000, Physical connectors
present: RJ45
    <6>  Primary interface chip i82555 PHY #1.
    <6>  General self-test: passed.
    <6>  Serial sub-system self-test: passed.
    <6>  Internal registers self-test: passed.
    <6>  ROM checksum self-test: passed (0xb874c1d3).
    <6>eth1: OEM i82557/i82558 10/100 Ethernet,
00:03:47:BD:60:87, IRQ 20.
    <6>  Board assembly fab600-000, Physical connectors
present: RJ45
    <6>  Primary interface chip i82555 PHY #1.
    <6>  General self-test: passed.
    <6>  Serial sub-system self-test: passed.
    <6>  Internal registers self-test: passed.
    <6>  ROM checksum self-test: passed (0xb874c1d3).

Looks like two NICs.
-- 
George Anzinger   george@mvista.com
High-res-timers: 
http://sourceforge.net/projects/high-res-timers/
Real time sched:  http://sourceforge.net/projects/rtsched/
Preemption patch:
http://www.kernel.org/pub/linux/kernel/people/rml
