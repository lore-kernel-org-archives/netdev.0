From: Patrick McHardy <kaber@trash.net>
Subject: Re: "ping6 -M do" fragments packets
Date: Fri, 12 Oct 2007 18:00:12 +0200
Message-ID: <470F9A0C.4080107@trash.net>
References: <20071012151841.GE3789@angus.ind.WPI.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chuck Anderson <cra@WPI.EDU>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62101 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801AbXJLQAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 12:00:51 -0400
In-Reply-To: <20071012151841.GE3789@angus.ind.WPI.EDU>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Anderson wrote:
> I'm not subscribed, so please Cc: me on any responses.  Thanks.
> 
> According to the man page, ping6 should support the "-M do" option so 
> never fragment packets, which I'd like to use for testing the MTU of a 
> path.  This option works fine for IPv4 ping, but doesn't work with 
> IPv6 ping6.  I can guarantee that I don't have an MTU of 63356 :-)
> 
> 
>>ping6 -M do -s 65527 www.kame.net
> 
> Sure enough, wireshark reports fragments:
> 
> No.     Time        Source                Destination           Protocol Info
>       1 0.000000    2001:468:616:8c9:213:72ff:fe74:da15 2001:200:0:8002:203:47ff:fea5:3085 IPv6     IPv6 fragment (nxt=ICMPv6 (0x3a) off=0 id=0x79)
>       2 0.000007    2001:468:616:8c9:213:72ff:fe74:da15 2001:200:0:8002:203:47ff:fea5:3085 IPv6     IPv6 fragment (nxt=ICMPv6 (0x3a) off=1448 id=0x79)


Are you using nf_conntrack_ipv6?
