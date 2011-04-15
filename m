From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ip: ip_options_compile() resilient to NULL skb route
Date: Thu, 14 Apr 2011 23:26:47 -0700 (PDT)
Message-ID: <20110414.232647.226789205.davem@davemloft.net>
References: <20110414123058.d4ffe7fb.shimoda.hiroaki@gmail.com>
	<1302796537.3248.22.camel@edumazet-laptop>
	<20110415082022.b5e50f9b.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com, lkml@scotdoyle.com,
	netdev@vger.kernel.org
To: shimoda.hiroaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44818
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752579Ab1DOG1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 02:27:22 -0400
In-Reply-To: <20110415082022.b5e50f9b.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date: Fri, 15 Apr 2011 08:20:22 +0900

> On Thu, 14 Apr 2011 17:55:37 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> Scot Doyle demonstrated ip_options_compile() could be called with an skb
>> without an attached route, using a setup involving a bridge, netfilter,
>> and forged IP packets.
>> 
>> Let's make ip_options_compile() and ip_options_rcv_srr() a bit more
>> robust, instead of changing bridge/netfilter code.
>> 
>> With help from Hiroaki SHIMODA.
>> 
>> Reported-by: Scot Doyle <lkml@scotdoyle.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Stephen Hemminger <shemminger@vyatta.com>
>> Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> Acked-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

Applied, thanks everyone.
