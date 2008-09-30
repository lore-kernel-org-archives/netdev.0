From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Tue, 30 Sep 2008 16:07:43 +0200
Message-ID: <48E232AF.7060501@bull.net>
References: <20080930063231.GA4792@ff.dom.local>	<48E212FF.1060409@bull.net> <20080930.065852.116510157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	dada1@cosmobay.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:34352 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752601AbYI3OIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 10:08:32 -0400
In-Reply-To: <20080930.065852.116510157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Benjamin Thery <benjamin.thery@bull.net>
> Date: Tue, 30 Sep 2008 13:52:31 +0200
> 
>> BTW, in the past (last year) dst_gc_task() was run as a timer
>> handler and this situation (deadlock with linkwatch_event())
>> couldn't occur.
> 
> September 12th to be exact :-)  That's when Eric Dumazet's
> change went in:
> 
> commit 86bba269d08f0c545ae76c90b56727f65d62d57f
> Author: Eric Dumazet <dada1@cosmosbay.com>
> Date:   Wed Sep 12 14:29:01 2007 +0200
> 
>     [PATCH] NET : convert IP route cache garbage collection from softirq processing to a workqueue
> 
> 
> But this change went into 2.6.24, so I wonder why it's taken
> so long to hit this.

Maybe because we manage to reproduce it only with network namespaces so
far and there isn't much netns users at the moment (and netns is still
incomplete in mainline).

Benjamin

> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
