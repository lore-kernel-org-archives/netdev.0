From: Ben Greear <greearb@candelatech.com>
Subject: Re: modifying tcp/ip stack
Date: Sat, 21 Aug 2004 00:01:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4126F363.9070205@candelatech.com>
References: <20040821054621.95115.qmail@web41403.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: net dev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: cranium2003 <cranium2003@yahoo.com>
In-Reply-To: <20040821054621.95115.qmail@web41403.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

cranium2003 wrote:
> Hello,
>         I want to modify existing protocol stack as
> given below.
>         What exactly i want to do is that i want to
> add a new protocol headerin between IP and ETHERNET
> header.
>         I want to implement packet structure as
> (Ethernet header +MY header + IP header +TCP header +
> PAYLOAD) that mean when packet comes from NIC it
> should first remove MY header in my routine then IP
> header in ip_input.c file.
>         Also at transmitting end packet at IP layer
> with (IP header + TCP header +PAYLOAD)structure passed
> to ip_output.c then given to my routine for adding a
> new protocol header on that packetand then to Ethernet
> layer.
>         I want your help to know what changes i
> require to do in kernel 2.4.24 to achieve this?
>          Please kindly reply me.

802.1Q vlan code does this.  See net/8021q/*

Ben

> Thaking you.
> 
> Regards,
> Parag.
> 
> 
> 		
> __________________________________
> Do you Yahoo!?
> Y! Messenger - Communicate in real time. Download now. 
> http://messenger.yahoo.com
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
