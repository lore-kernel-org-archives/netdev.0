From: Tim Schneider <schneid5@cs.uni-bonn.de>
Subject: Re: Using Wireless Extensions in a Kernel Module
Date: Mon, 13 Jul 2009 08:24:36 +0200
Message-ID: <9A4B18C9-91B4-4B9B-A147-49C3BB04E296@cs.uni-bonn.de>
References: <A353FA76-7D71-425F-BD67-FEE6DC26EF6F@cs.uni-bonn.de> <4A5850E7.5020708@gdt.id.au>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix.iai.uni-bonn.de ([131.220.8.4]:57034 "EHLO
	postfix.iai.uni-bonn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbZGMGYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 02:24:40 -0400
Received: from [10.0.1.10] (dslb-084-063-085-116.pools.arcor-ip.net [84.63.85.116])
	by postfix.iai.uni-bonn.de (Postfix) with ESMTP id 377315C828
	for <netdev@vger.kernel.org>; Mon, 13 Jul 2009 08:24:38 +0200 (MEST)
	(envelope-from schneid5@cs.uni-bonn.de)
	(envelope-to netdev@vger.kernel.org) (1)
	(internal use: ta=1, tu=1, te=1, am=P, au=schneid5)
In-Reply-To: <4A5850E7.5020708@gdt.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Glen, hi Marcel

thank you for your answers.

I am trying to develop the algorithm for a wireless multihop network,  
so no, I'm not making the classical error ;) Still you're right that I  
should consider the possibility, that the Algorithm is used on a wired  
network. In that case it definitely should not crash the whole system.

Thank you for your hint with the other mailing list. I'm going to try  
my luck there.

Regards

Tim

Am 11.07.2009 um 10:44 schrieb Glen Turner:
>
> Hi Tim,
>
> I'm not sure you aren't making a classic error of optimising the  
> unusual
> case.
>
> The usual situation is that the TCP sender is on the wired network,  
> the
> TCP receiver is on the wireless network. Since the sender determines  
> the
> packet scheduling, determining the received signal strength at the TCP
> receiver isn't much help.
>
> What would be really, really useful is a channel to get this sort of
> information back to the sender in a form in which the feedback is  
> useful
> even after a RTT/2 delay. There are a few explicit congestion  
> notification
> protocols around, and adapting one of those to add the wireless  
> condition
> of intermediate and end hops could be the sort of useful  
> augmentation that
> gives these protocols enough of an advantage of TCP to be worth  
> deploying.
>
> Best wishes, Glen
>
> -- 
> Glen Turner   <http://www.gdt.id.au/~gdt/>

