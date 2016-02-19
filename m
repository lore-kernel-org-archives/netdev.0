From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2] sctp: Fix port hash table size computation
Date: Fri, 19 Feb 2016 15:41:09 +0100
Message-ID: <1455892869.648.22.camel@edumazet-ThinkPad-T530>
References: <20160218.153921.2010668846576353053.davem@davemloft.net>
	 <1455829857-15797-1-git-send-email-nhorman@tuxdriver.com>
	 <1455877730.648.21.camel@edumazet-ThinkPad-T530>
	 <20160219140703.GA20372@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Dmitry Vyukov <dvyukov@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:36799 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424112AbcBSOlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 09:41:13 -0500
In-Reply-To: <20160219140703.GA20372@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ven., 2016-02-19 at 09:07 -0500, Neil Horman wrote:

> I had actually thought about that, but to be frank I felt like the logic to
> compute the hashsize was complex the way it was presented currently, and that my
> rewite made it more clear, breaking it down into a few easy steps:
> 
> 1) compute a goal size order
> 2) compute the target order for the largest table we want to support
> 3) select the minimum of (1) and (2)
> 4) allocated the largest table we can up to the size in (3)
> 5) compute how many buckets the table we allocated in (4) supports
> 
> 
> I'm happy to use your suggestion above if the consensus is that its more clear,
> but it took me a bit to figure out what exactly the existing code was trying to
> do (especially given the dual use of the order variable), so I thought some
> additional clarity was called for.

No strong feelings. I only took a look in other places like
net/dccp/proto.c for similar problem.
