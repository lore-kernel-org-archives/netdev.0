From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Fri, 08 Jan 2010 16:48:11 -0500
Message-ID: <4B47A81B.5040601@majjas.com>
References: <4B459368.2000503@majjas.com> <4B45F841.8030407@majjas.com>
 <20100107180114.GB3088@del.dom.local> <4B4625BD.3070202@majjas.com>
 <20100107183545.GA3208@del.dom.local> <4B462B3C.90506@majjas.com>
 <20100107185040.GB3208@del.dom.local> <4B466A26.5070506@majjas.com>
 <20100108074539.GA6205@ff.dom.local> <4B475FF9.7000702@majjas.com>
 <20100108212923.GA3078@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754138Ab0AHVss@vger.kernel.org>
In-reply-to: <20100108212923.GA3078@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/8/2010 4:29 PM, Jarek Poplawski wrote:
> On Fri, Jan 08, 2010 at 11:40:25AM -0500, Michael Breuer wrote:
>    
>> On 1/8/2010 2:45 AM, Jarek Poplawski wrote:
>>      
>> ...
> Berck Nash reported oopses during sky2 TX timeout recovery, which are
> generally hardware/driver problems, and shouldn't be triggered by ip
> level bugs, so it should be queried as a separate bug report.
>
>    
My thought was that his crash was secondary to the netdev watchdog & 
subsequent reset that I saw.
>> Will try rerunning without disable_msi later (after I catch the dns
>> thing in the sniffer).
>>      
>>>> I'm leaving this one running for now. Not retesting jumbo for now. Be
>>>> happy to help dig further.
>>>>
>>>> Tentative recommendations:
>>>>
>>>> 1) The af alternative patch seems rather necessary. First alternative
>>>> seems to be working, I'd suggest that be submitted and backported to
>>>> 2.6.32.
>>>>          
> BTW, don't hurry with that yet, but in the next test, please try
> alternative 2 again (i.e. with MMAP + no DMAR + disable_msi).
>
>    
Will do - still up from yesterday... no more dropped packets... none of 
the dns errors either. To be expected I suppose as long as I'm trying to 
sniff it. Assuming no immediate erorrs with alt2, no DMAR + disable_msi 
I'll report back after it's been up for a while.
