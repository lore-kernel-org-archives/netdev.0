From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Mon, 05 Dec 2005 18:03:02 -0500
Message-ID: <4394C726.80902@psc.edu>
References: <200512022253.19029.a1426z@gawab.com>	<200512031646.45332.a1426z@gawab.com>	<4391E4FC.1040200@candelatech.com>	<20051205140057.GC24764@tuxdriver.com>	<20051205174010.GA14101@buici.com>	<43947FEB.7020504@unfix.org> <4394BCD5.1060505@psc.edu>	<4394BF11.2070205@hp.com> <4394BF9E.90303@psc.edu> <4394C2A9.6000606@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeroen Massar <jeroen@unfix.org>, Marc Singer <elf@buici.com>,
	Ben Greear <greearb@candelatech.com>,
	Al Boldi <a1426z@gawab.com>, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@vger.kernel.org
In-Reply-To: <4394C2A9.6000606@hp.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> John Heffner wrote:
>> Yes, but if an interface will accept packets for a certain IP address, 
>> and will send packets with that IP address, is there any reason it 
>> can't ARP for that address?
> 
> 
> If ARP RFC's say it shouldn't :) (I don't know that it does) ARP is ARP, 
> accepting IPs is IP.  The maze of twisty passages may be similar, but 
> they are distinct.

I actually think it would be out of scope for an ARP RFC to specify this 
(and none I'm aware of do).  It really is an IP layer decision.  That 
is, the decision naturally extends beyond the scope of ARP, applying 
also to layer 2 devices which don't even do ARP.


> Is a MAC address a property of the host, or of the interface connected 
> to the host?

Depends on whether you run your interfaces in promiscuous mode, and send 
frames with different MAC addresses from one interface. ;-)

   -John
