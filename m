From: David Miller <davem@davemloft.net>
Subject: Re: RFC: New BGF 'LOOP' instruction
Date: Tue, 03 Aug 2010 00:19:04 -0700 (PDT)
Message-ID: <20100803.001904.63020040.davem@davemloft.net>
References: <20100802201629.GA5973@nuttenaction>
	<20100802.221813.43045517.davem@davemloft.net>
	<20100803070709.GO11110@cel.leo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hagen@jauu.net
To: leonerd@leonerd.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59597
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755396Ab0HCHSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 03:18:46 -0400
In-Reply-To: <20100803070709.GO11110@cel.leo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Date: Tue, 3 Aug 2010 08:07:10 +0100

> On Mon, Aug 02, 2010 at 10:18:13PM -0700, David Miller wrote:
>> 1) The limiting scheme will make legitimate scripts USELESS
> 
> Rightnow, BPF is all but useless for parsing, say, IPv6. I only pick
> IPv6 as one example, I'm sure there must exist a great number more
> packet-based protocols that use a "linked-list" style approach to
> headers. None of those are currently filterable on the current set of
> instructions. LOOP would allow these.

It's not meant for detailed packet protocol header analysis,
it's for stateless straight line matching of masked values
in packet headers.

Nothing more.
