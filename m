From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Mon, 05 Dec 2005 14:43:53 -0800
Message-ID: <4394C2A9.6000606@hp.com>
References: <200512022253.19029.a1426z@gawab.com>	<200512031646.45332.a1426z@gawab.com>	<4391E4FC.1040200@candelatech.com>	<20051205140057.GC24764@tuxdriver.com>	<20051205174010.GA14101@buici.com>	<43947FEB.7020504@unfix.org> <4394BCD5.1060505@psc.edu>	<4394BF11.2070205@hp.com> <4394BF9E.90303@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeroen Massar <jeroen@unfix.org>, Marc Singer <elf@buici.com>,
	Ben Greear <greearb@candelatech.com>,
	Al Boldi <a1426z@gawab.com>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <4394BF9E.90303@psc.edu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Heffner wrote:
> Rick Jones wrote:
> 
>> That's the discussion related to things like the "Strong ES" (end 
>> system) model right?  As such, isn't that discussing what _IP_ may do 
>> rather than what ARP may do?  1122 doesn't say much about the 
>> interfaces/MAC's that should be part of a given ARP reply.  ARP seems 
>> to be RFC 826 and probably others, and the algorithm described in 826 
>> doesn't seem to be specific on the topic of interfaces - at least not 
>> to my really brief read.
>>
>> rick jones
> 
> 
> Yes, but if an interface will accept packets for a certain IP address, 
> and will send packets with that IP address, is there any reason it can't 
> ARP for that address?

If ARP RFC's say it shouldn't :) (I don't know that it does) ARP is ARP, 
accepting IPs is IP.  The maze of twisty passages may be similar, but they are 
distinct.

Is a MAC address a property of the host, or of the interface connected to the host?

rick jones
is on netdev, so no need for direct reply to my address...
