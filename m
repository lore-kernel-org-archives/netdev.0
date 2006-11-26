From: James Courtier-Dutton <James@superbug.co.uk>
Subject: Re: gratuitous arp
Date: Sun, 26 Nov 2006 02:05:23 +0000
Message-ID: <4568F663.7090805@superbug.co.uk>
References: <Pine.LNX.4.64.0611251526040.8068@twinlark.arctic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchor-post-35.mail.demon.net ([194.217.242.85]:42760 "EHLO
	anchor-post-35.mail.demon.net") by vger.kernel.org with ESMTP
	id S967140AbWKZCF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Nov 2006 21:05:26 -0500
To: dean gaudet <dean@arctic.org>
In-Reply-To: <Pine.LNX.4.64.0611251526040.8068@twinlark.arctic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dean gaudet wrote:
> hi...
> 
> i ran into some problems recently which would have been avoided if my box 
> did a gratuitous arp as it brought up all interfaces (the router took 
> forever to timeout the ARP entries for interface aliases).  so i set about 
> looking to see why that wasn't happening.
> 
> i either missed it, or there's no code in the kernel to do it -- but 
> that's cool, because it's easy enough to do from userland.  i'm guessing 
> this is the intention.
> 
> however my debian and ubuntu boxes aren't doing grat arp and don't seem to 
> have options to do it (i do know about using various other tools such as 
> arping, send_arp, garp to do it manually).
> 
> before i go opening bugs with the distribution folks, could someone chime 
> in as to what is the recommended approach these days?  did grat arp fall 
> out of favour, or is it just a case of userland not keeping up?
> 
> thanks
> -dean

Are you 100% sure about this?
Have you done a packet sniff on the network?
A lot of routers ignore gratuitous arp for security reasons.

James

