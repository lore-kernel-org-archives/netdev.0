From: Patrick McHardy <kaber@trash.net>
Subject: Re: sky bugs in 2.6.22-rc5
Date: Mon, 18 Jun 2007 22:00:24 +0200
Message-ID: <4676E458.2040101@trash.net>
References: <4676E1DD.1060007@trash.net> <20070618125118.10c9b6d9@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41382 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762495AbXFRUA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 16:00:26 -0400
In-Reply-To: <20070618125118.10c9b6d9@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Mon, 18 Jun 2007 21:49:49 +0200
> Patrick McHardy <kaber@trash.net> wrote:
> 
> 
>>sky2 breaks reproducably in 2.6.22-rc5 when setting the interface
>>down and up again. Packets are not received on the other side,
>>after a short time tcpdump (on the sky2 side) shows
>>use-after-free patterns:
>>
> 
> 
> Haven't seen this, but seems odd.


Its 100% reproducable here by doing "ifconfig eth0 down; ifconfig
eth0 up".

>>The reason for the second problem seems to be that sky2 enables
>>the queue too early and netconsole sends packets before
>>initialization is complete when sky2_up() prints a message.
> 
>  
> Are you using large MTU?


No. I just tried to verify my "wakes queue to early" theory by
pulling the cable before setting the device up again and it still
crashed. If you want me to test anything just say so.
