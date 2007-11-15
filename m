From: Divy Le Ray <divy@chelsio.com>
Subject: Re: reproducible cxgb kernel panic in FC8 kernel 2.6.23.1-49
Date: Thu, 15 Nov 2007 03:46:55 -0800
Message-ID: <473C31AF.9030300@chelsio.com>
References: <473A67CA.8030007@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:2181 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752495AbXKOLrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 06:47:00 -0500
In-Reply-To: <473A67CA.8030007@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> This panic happens (almost?) immediately after starting TCP traffic 
> between
> the cxgb nic on this system and another.  We also got at least one crash
> on a custom/tainted 2.6.20.12 kernel, but it would run for at least
> a few minutes at ~1Gbps first.
>
> I think my serial console chomped some of this..but it's very 
> reproducible,
> so if you need more info I can make the terminal wider and do it again.
>
Hi Ben,

I just posted a patch fixing this T2 crash. It appeared in 2.6.22, when 
eth_type_trans()
was modified to set skb->dev. cxgb3 got fixed at the time, but I 
obviously forgot the
chelsio driver. I'm a bit behind on T2 updates. I will get to it in a 
few days.

Cheers,
Divy

