From: David Greaves <david@dgreaves.com>
Subject: Re: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out+ delay
 scheduler
Date: Mon, 21 Jun 2004 18:29:19 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D71AEF.8030006@dgreaves.com>
References: <40CDD68C.8070509@dgreaves.com>	 <20040615155111.26d6b809@dell_ss3.pdx.osdl.net>	 <40D0280B.2030308@dgreaves.com>	 <Pine.LNX.4.60.0406180953240.1089@jlaas2.data.slu.se>	 <40D2B114.5020201@dgreaves.com> <1087836178.20902.23.camel@tubarao>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jens Laas <jens.laas@data.slu.se>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com, ganesh.venkatesan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tharbaugh@lnxi.com
In-Reply-To: <1087836178.20902.23.camel@tubarao>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thayne Harbaugh wrote:

>On Fri, 2004-06-18 at 03:08, David Greaves wrote:
>
>  
>
>>Jens Laas wrote:
>>    
>>
>>>We have tried different versions of e1000 without luck.
>>>      
>>>
>>Me too, 3 cards.
>>(did I mention I have 2 machines with very similar specs (AMD/VIAKT600) 
>>and the other one works - actually, to be accurate, hasn't yet failed 
>>but hasn't yet run at full speed - and it has a higher CPU speed)
>>    
>>
>
>What do you mean by, ". . . hasn't yet run at full speed - and it has a
>higher CPU speed . . ." ?  Does this mean that you can't get the card to
>have a reasonable throughput (~900Mbps)?
>
>  
>

It sounded reasonable when I wrote it :)

I have 2 machines I can easily test with (wired back to back)
Machine 1 has an AMD3000+ CPU, machine 2 has an AMD3200+ cpu (maybe not 
relevant - maybe important if it's timing related?)

Machine one  stalls within a few kb.
Machine two has shown no signs of failure yet.

However the other machine has not been stressed at all so it has 'not 
yet run at full speed' - not surprising since it has no friends with 
working gigabit cards :)

David
PS
I tried some experiments this weekend with a third machine but I got 
nasty kernel oopses on the second (supposedly good) whenever I did 
ifconfig eth1 mtu 9000 and I've not had time to get any proper results 
or a minimal failure yet.

simply issuing
ifconfig eth1 mtu 9000
on the second machine gave me this:

Jun 18 16:33:08 haze kernel: printk: 1 messages suppressed.
Jun 18 16:33:08 haze kernel: ifconfig: page allocation failure. order:3, 
mode:0x20
Jun 18 16:33:08 haze kernel:  [__alloc_pages+728/848] 
__alloc_pages+0x2d8/0x350
Jun 18 16:33:08 haze kernel:  [__get_free_pages+37/64] 
__get_free_pages+0x25/0x40
Jun 18 16:33:08 haze kernel:  [kmem_getpages+32/176] kmem_getpages+0x20/0xb0
Jun 18 16:33:08 haze kernel:  [cache_grow+166/512] cache_grow+0xa6/0x200
Jun 18 16:33:08 haze kernel:  [cache_alloc_refill+342/544] 
cache_alloc_refill+0x156/0x220
Jun 18 16:33:08 haze kernel:  [__kmalloc+116/128] __kmalloc+0x74/0x80
...

I'll report more fully when I can produce something consistent.
