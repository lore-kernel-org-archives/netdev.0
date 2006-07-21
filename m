From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 21 Jul 2006 09:26:42 -0700
Message-ID: <44C10042.1020503@hp.com>
References: <20060720164100.GA9213@ms2.inr.ac.ru>	<20060720210849.GA28715@tservice.net.ru>	<20060720225908.GA18362@ms2.inr.ac.ru> <20060720.215504.41641534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:61402 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S1751073AbWGUQ0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 12:26:46 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060720.215504.41641534.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> All this talk reminds me of one thing, how expensive tcp_ack() is.
> And this expense has nothing to do with TCP really.  The main cost is
> purging and freeing up the skbs which have been ACK'd in the
> retransmit queue.
> 
> So tcp_ack() sort of inherits the cost of freeing a bunch of SKBs
> which haven't been touched by the cpu in some time and are thus nearly
> guarenteed to be cold in the cache.
> 
> This is the kind of work we could think about batching to user
> sleeping on some socket call.

Ultimately isn't that just trying to squeeze the balloon?

rick jones

nice to see people seeing ACKs as expensive though :)
