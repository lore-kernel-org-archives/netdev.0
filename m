From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH] TCP: check min TTL on received ICMP packets
Date: Sat, 20 Mar 2010 17:05:14 -0700 (PDT)
Message-ID: <27142077.3891269129914984.JavaMail.root@tahiti.vyatta.com>
References: <20100319.210801.39166378.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pekkas@netcore.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54492 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752759Ab0CUAFZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Mar 2010 20:05:25 -0400
In-Reply-To: <20100319.210801.39166378.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


----- "David Miller" <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 18 Mar 2010 14:27:32 -0700
> 
> > This adds RFC5082 checks for TTL on received ICMP packets.
> > It adds some security against spoofed ICMP packets
> > disrupting GTSM protected sessions.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>   
> Applied.
> 
> > Please apply to 2.6.33 since it basically a "follow correct RFC"
> > fix to original GTSM patch.
> 

I meant 2.6.34... min_ttl is not in 2.6.33
