From: "Mala Anand" <manand@us.ibm.com>
Subject: Re: Network oops
Date: Mon, 10 Jun 2002 09:42:10 -0500
Sender: owner-netdev@oss.sgi.com
Message-ID: <OFFF217683.8ACE4FCF-ON85256BD4.004D1229@raleigh.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@muc.de, "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
   linux-net@vger.kernel.org, linux-net-owner@vger.kernel.org,
   netdev@oss.sgi.com, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: george anzinger <george@mvista.com>
List-Id: netdev.vger.kernel.org

>"David S. Miller" wrote:
>>
>> Also we need to know what network driver, if preemption is being
>> used (being from mvista I assume you are using preemption, and if
>> so make sure you have the preemption networking patches applied).

>Uh, are you saying there is a set of network patches?  If
>so, where might they be found?  And yes, we are testing
>preemption, trying to wring out the "last" bug :)  (Could
>you be referring to the patches we are developing?)

>The driver (from the system log):
>    <4>eepro100.c:v1.09j-t 9/29/99 Donald Becker
>http://cesdis.gsfc.nasa.gov/linux/drivers/eepro100.html
>    <4>eepro100.c: $Revision: 1.36 $ 2000/11/17 Modified by
>Andrey V. Savochkin <saw@saw.sw.com.sg> and others
>    <6>eth0: OEM i82557/i82558 10/100 Ethernet,
>00:03:47:BD:60:86, IRQ 21.
>    <6>  Board assembly fab600-000, Physical connectors
>present: RJ45
>    <6>  Primary interface chip i82555 PHY #1.
> <6>  General self-test: passed.
>    <6>  Serial sub-system self-test: passed.
>    <6>  Internal registers self-test: passed.
>    <6>  ROM checksum self-test: passed (0xb874c1d3).
>    <6>eth1: OEM i82557/i82558 10/100 Ethernet,
>00:03:47:BD:60:87, IRQ 20.
>    <6>  Board assembly fab600-000, Physical connectors
>present: RJ45
>    <6>  Primary interface chip i82555 PHY #1.
>    <6>  General self-test: passed.
>    <6>  Serial sub-system self-test: passed.
>    <6>  Internal registers self-test: passed.
>    <6>  ROM checksum self-test: passed (0xb874c1d3).

>Looks like two NICs.
--
 I have see this problem with this NIC.  You need to increase
the number of buffers in the RX and TX ring in eepro100.c file.
Right now it is set to 32, change it to 256 or 128 this error
will go away.

Regards,
    Mala


   Mala Anand
   E-mail:manand@us.ibm.com
   Linux Technology Center - Performance
   Phone:838-8088; Tie-line:678-8088
