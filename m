From: Patrick McHardy <kaber@trash.net>
Subject: Re: "ping6 -M do" fragments packets
Date: Fri, 12 Oct 2007 19:17:50 +0200
Message-ID: <470FAC3E.7050501@trash.net>
References: <20071012151841.GE3789@angus.ind.WPI.EDU> <470F9A0C.4080107@trash.net> <20071012163202.GW4751@angus.ind.WPI.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chuck Anderson <cra@WPI.EDU>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63563 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762633AbXJLRSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 13:18:31 -0400
In-Reply-To: <20071012163202.GW4751@angus.ind.WPI.EDU>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Anderson wrote:
> On Fri, Oct 12, 2007 at 06:00:12PM +0200, Patrick McHardy wrote:
> 
>>>>ping6 -M do -s 65527 www.kame.net
>>>
>>>Sure enough, wireshark reports fragments:
>>>
>>>No.     Time        Source                Destination           Protocol Info
>>>      1 0.000000    2001:468:616:8c9:213:72ff:fe74:da15 2001:200:0:8002:203:47ff:fea5:3085 IPv6     IPv6 fragment (nxt=ICMPv6 (0x3a) off=0 id=0x79)
>>>      2 0.000007    2001:468:616:8c9:213:72ff:fe74:da15 2001:200:0:8002:203:47ff:fea5:3085 IPv6     IPv6 fragment (nxt=ICMPv6 (0x3a) off=1448 id=0x79)
>>
>>Are you using nf_conntrack_ipv6?
> 
> 
> No:
> 
> [...]


Works for me:

$ ping6 -M do -s 65527 www.kame.net -n -c 1
PING www.kame.net(2001:200:0:8002:203:47ff:fea5:3085) 65527 data bytes
>From 2001:6f8:974:0:21b:21ff:fe02:6fad icmp_seq=1 Packet too big: mtu=1500

--- www.kame.net ping statistics ---
0 packets transmitted, 0 received, +1 errors

