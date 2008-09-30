From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Tue, 30 Sep 2008 17:18:25 +0200
Message-ID: <48E24341.5050609@bull.net>
References: <48E212FF.1060409@bull.net> <20080930144203.GA2511@ami.dom.local> <20080930145710.GB2511@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:44405 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208AbYI3PSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 11:18:40 -0400
In-Reply-To: <20080930145710.GB2511@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Tue, Sep 30, 2008 at 04:42:04PM +0200, Jarek Poplawski wrote:
>> Benjamin Thery wrote, On 09/30/2008 01:52 PM:
> ...
>>> I'm still looking at why the first dst_free() on those particular routes 
>>> doesn't call dst_destroy() immediately but defers it (another refcount
>>> on the route itself).
>> Yes, finding/fixing this, if possible, in this place looks like the
>> most consistent with the way netdev_wait_allrefs() is handling this.
> 
> Actually, I wonder, why we can't simply run this dst_gc_task() from
> dst_dev_event() (after cancelling the work) when needed.
> 

Um... I haven't thought about this. I'll have a look to see if it can
solve our issue.


Benjamin

> Jarek P.
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
