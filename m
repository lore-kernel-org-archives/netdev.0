From: Ben Greear <greearb@candelatech.com>
Subject: Re: Update on e1000 troubles (over-heating!)
Date: Mon, 07 Oct 2002 09:40:13 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3DA1B8ED.2000309@candelatech.com>
References: <Pine.GSO.4.30.0210070749430.1861-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andre Hedrick <andre@pyxtechnologies.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: jamal <hadi@cyberus.ca>
List-Id: netdev.vger.kernel.org

jamal wrote:
> 
> On Sun, 6 Oct 2002, Ben Greear wrote:
> 
> 
>>I can reproduce my crash using mtu sized pkts running only 50Mbps
>>send + receive on 2 nics.  It took over-night to do it though.  Running
>>as hard as I can with MTU packets will crash it as well, and much
>>quicker.
>>
> 
> 
> So is there a correlation with packet count then?

No, running at slower speeds (50Mbps), the packet count was well over
4 billion (ie it successfully wrapped 32-bits).  At higher speeds, it
crashes before the 32-bit wrap, generally.  It also does not coorelate
to bytes-sent/received, or anything else that I could think of to look at.

> 
> 
> 
>>Interestingly enough, the tg3 NIC (netgear 302t), registered 57 deg C between
>>the fins of it's heat sink in the 32-bit slots.  Makes me wonder if my PCI bus
>>is running too hot :P
> 
> 
> Does the problem happen with the tg3?

As Dave mentioned, tg3 locks up almost immediately (like within 30 seconds),
and in the meantime, it's spitting out errors that are 'impossible'.  The
messages I sent a day or two ago.

I may have cooked my cards, or something like that, because one of
the tg3's do not work in my other machine now.  Still trouble-shooting that one.

Ben


> 
> cheers,
> jamal
> 
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
