From: Patrick McHardy <kaber@trash.net>
Subject: Re: Adding IPv6 support to IPVS: some general questions about kernel
 development
Date: Mon, 31 Mar 2008 19:47:49 +0200
Message-ID: <47F123C5.70804@trash.net>
References: <f4845fc0803310753o56ccbae5uda1e216fa139857@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julius Volz <juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64707 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbYCaRrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 13:47:52 -0400
In-Reply-To: <f4845fc0803310753o56ccbae5uda1e216fa139857@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julius Volz wrote:
> I was redirected here from lvs-devel for a particular question. As
> part of an internship at Google, I am currently looking at porting the
> IPVS (IP virtual server) kernel part of LVS to support IPv6. First
> off, I am neither a real specialist in any of the involved areas yet
> (IPv6, load balancing) nor do I have much experience writing kernel
> code (mainly reading it for some time now), but I will try to learn as
> much as I can each day. Do expect lots of newbie questions though ;)
> 
> One question I had on lvs-devel that people here might know more
> about: IPVS is currently sitting at "net/ipv4/ipvs/..." in the kernel.
> A lot of this code would probably be the same for an IPv6 version, so
> the code would have to be refactored somehow and partially moved to a
> location where it can be used by both the IPv4 and IPv6 code. Are
> there any special rules for this and what do I have to think of? For
> example, could I just move the common code to a directory "net/ipvs"
> (or even all of the code, for both IPv4 and IPv6) or would people
> object?

net/ipvs or net/netfilter/ipvs sound fine. The second is probably
better since at some point we should try to merge the duplicated
conntrack functionality if possible.
