From: Ben Greear <greearb@candelatech.com>
Subject: Re: Network card driver problem (znb.o/tulip)
Date: Thu, 19 May 2005 10:14:00 -0700
Message-ID: <428CC958.1080909@candelatech.com>
References: <efe3b00605031021513b7268d1@mail.gmail.com> <efe3b00605051901022854653a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, tulip-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kosta Todorovic <kostodo@gmail.com>
In-Reply-To: <efe3b00605051901022854653a@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kosta Todorovic wrote:
> Whats the best 4-port NIC currently available? I'm interested in
> purchasing 10 4-port NICs as a replacement for my current cards.
> 
> I am looking for 10/100Mbps and a good driver for linux (2.4.x and
> 2.6.x). Preferably a mainstream company but thats not priority.
> 
> Could the community please recommend the best card available? Money is
> not an issue since im really interested in the best of the best.

Get an Intel 4-port GigE NIC.  It will do 10/100/1000, and if you really
want to use all 4 ports at even 100Mbps, you need the 64-bit PCI bus...

I have been getting mine from silicom-usa.com lately.  They also have
6-port NICs, and 4-port broadcom GigE nics that can be used in 32-bit
PCI slots.  (The Intel 4-port NICs will only work in 64-bit PCI slots.)

If you really want 10/100 nics, try the p430tx from aei:
http://www.aei-it.com/hardware/fastenet/p430tx.htm

These are like the old DFE570tx NICs, and use the tulip driver.  They
are almost as expensive as the GigE NICs though...

Thanks,
Ben

> 
> Any suggestions?
> 
> Regards,
> Kosta
> 
> 
> 
> On 3/11/05, Kosta Todorovic <kostodo@gmail.com> wrote:
> 
>>My company has recently purchased several ZNYX ZX274 network cards.
>>These cards are Four Channel, 10/100 PCI Adapters. They use Intel chipsets.
>>
>>Unfortunately there exists no drivers for linux amd64 architecture.
>>There are 32bit drivers found at:
>>http://www.znyx.com/support/drivers/ZX374_drivers.htm but naturally
>>they wont compile under my amd64 system.
>>
>>The driver itself is called znb.o and can be downloaded from ZNYX's
>>website. I spoke to support staff there but they told me they have
>>discontinued support and development for this series of cards.
>>
>>The system I am running gentoo and have tried both 2.4.x and 2.6.x
>>kernels but no luck.
>>
>>Unfortunately there is NO 64bit drivers available for ANY platform. not even MS.
>>
>>Does anyone know of a customised znb.o driver built for amd64?
>>Is there any chance of anyone modifying the source code of the driver
>>to compile under a amd64 system?
>>
>>I've noticed that "tulip" drivers get loaded as a module at boot time.
>>but they dont function correctly. (lets you start the device and
>>attach ips but cant talk through it)
>>
>>Is there any variants of the tulip driver that will work for this?
>>
>>Help much appreciated.
>>
>>
>>/proc/pci extract for network cards:
>>
>>  Bus  5, device   5, function  0:
>>    Ethernet controller: Digital Equipment Corporation DECchip
>>21142/43 (#30) (rev 65).
>>      IRQ 30.
>>      Master Capable.  Latency=128.  Min Gnt=20.Max Lat=40.
>>      I/O at 0x0 [0x7f].
>>      Non-prefetchable 32 bit memory at 0xfa1ff400 [0xfa1ff7ff].
>>  Bus  5, device   4, function  0:
>>    Ethernet controller: Digital Equipment Corporation DECchip
>>21142/43 (#29) (rev 65).
>>      IRQ 29.
>>      Master Capable.  No bursts.  Min Gnt=20.Max Lat=40.
>>      I/O at 0x0 [0x7f].
>>      Non-prefetchable 32 bit memory at 0xf9f00000 [0xf9f003ff].
>>
> 
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
