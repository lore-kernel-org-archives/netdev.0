From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 01 Feb 2008 13:58:30 -0800
Message-ID: <47A39606.4090401@hp.com>
References: <20080131124632.GA25299@basil.nowhere.org>	<47A212CB.1060403@hp.com> <20080131190326.GF4671@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:46754 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755452AbYBAV6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 16:58:33 -0500
In-Reply-To: <20080131190326.GF4671@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>Does this also imply that JumboFrames interacts badly with these qdiscs? 
>> Or IPoIB with its 65000ish byte MTU?
> 
> 
> Correct. Of course it is always relative to the link speed. So if your
> link is 10x faster and your packets 10x bigger you can get similarly
> smooth shaping.

If the later-in-thread mentioned person shaping for their DSL line 
happens to have enabled JumboFrames on their GbE network, will/should 
the qdisc negate that?  Or is the qdisc currently assuming that the 
remote end of the DSL will have asked for a smaller MSS?

rick jones
