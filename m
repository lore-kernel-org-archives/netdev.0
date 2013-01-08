From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [RFC patch net-next] ipv4: use bcast as dst address in case
 IFF_NOARP is set
Date: Tue, 8 Jan 2013 22:51:47 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1301082245570.18402@nerf07.vanv.qr>
References: <0355baea-4761-477b-a68a-cd40fd5033b8@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
	edumazet@google.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	pavlix@pavlix.net
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:43295 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754239Ab3AHVvs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2013 16:51:48 -0500
In-Reply-To: <0355baea-4761-477b-a68a-cd40fd5033b8@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2013-01-08 20:10, Stephen Hemminger wrote:
>> 
>>Also, what is the issue with sending all packets to broadcast when
>>NOARP is set? In my opinion, it only makes sense.
>
>It looks like NOARP devices are point-to-point and don't really have
>any concept of broadcast.

PTP links usually are NOARP, but NOARP does not necessarily imply
a PTP link.
