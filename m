From: Chris Larson <clarson@mvista.com>
Subject: Re: MV643xx Ethernet Driver Issue on a Motorola PrPMC-275 board.
Date: Thu, 31 Jul 2008 09:44:17 -0700
Message-ID: <4891EBE1.3070606@mvista.com>
References: <488F5815.9020402@mvista.com> <20080730235622.GA22826@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:52447 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbYGaQoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 12:44:11 -0400
In-Reply-To: <20080730235622.GA22826@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> On Tue, Jul 29, 2008 at 10:49:09AM -0700, Chris Larson wrote:
>>  was wondering if anyone had any advice on an issue a customer of ours 
>> is running into.  When they run a series of bandwidth tests, slowly 
>> increasing the bandwidth & # of tcp connections to roughly 30Mbit at 
>> 4000 connections, their machine panics.  An address passed to 
>> dma_unmap_single is beyond lowmem, as though it was corrupted in some 
>> fashion.  The address is the data pointer in the ethernet dma 
>> descriptors, it pulls a descriptor out of the ring in the packet receipt 
>> functions and at that point the address is wrong.  Nowhere in the driver 
>> is a descriptor set up with that address, yet the datasheet on the 
>> mv643xx doesn't seem to indicate that the dma engine ever writes to the 
>> descriptors themselves, only to the data they point to (as you'd 
>> expect).  Does anyone have any ideas on this?  I'm afraid that I'm a bit 
>> out of my depth on this issue.  The architecture is ppc.
>>     
>
> I've never seen this happen.  Which kernel version is this on?
>   
One of MontaVista's 2.6.10 trees, too heavily modified to be of much use 
to you, I'm certain. Most of the recent mv643xx patches are in our tree, 
as one of our developers was the old maintainer. It doesn't occur in 
2.4, not that that's very helpful :) I can try to reproduce with a more 
recent tree and let you know. Thanks for your time.
-- 

Chris Larson
clarson at kergoth dot com
clarson at mvista dot com
Software Engineer
MontaVista Software, Inc.

