From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: jumbo frames and memory fragmentation
Date: Fri, 30 Jun 2006 17:35:34 -0600
Message-ID: <44A5B546.3010606@nortel.com>
References: <E1FwIcw-00068x-00@gondolin.me.apana.org.au> <44A56520.5010703@nortel.com> <20060630184820.GA9558@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04f.nortel.com ([47.129.242.57]:58582 "EHLO
	zcars04f.nortel.com") by vger.kernel.org with ESMTP id S932415AbWF3Xfq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 19:35:46 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060630184820.GA9558@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:

> It definitely will.
> Packet split in hardware means separating data and headers into
> different pages in different reads, while software page split means that 
> skb has a list of fragments where part of the packet will be DMAed, so
> jumbo frame will be converted into several pages.

Maybe I'm looking at the wrong code then.  Can you point me to where 
this "software page split" is handled?

Chris
