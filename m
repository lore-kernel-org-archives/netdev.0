From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] remove an unnecessary field in struct tcp_skb_cb
Date: Thu, 13 Nov 2008 22:55:40 -0800 (PST)
Message-ID: <20081113.225540.34583336.davem@davemloft.net>
References: <1226571707.18006.23.camel@nathan.suse.cz>
	<491C6DA6.8030200@gmail.com>
	<87fxlvcsam.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hummerbliss@gmail.com, ptesarik@suse.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60448
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751126AbYKNGzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 01:55:41 -0500
In-Reply-To: <87fxlvcsam.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Thu, 13 Nov 2008 20:57:53 +0100

> Saikiran Madugula <hummerbliss@gmail.com> writes:
> 
> > Petr Tesarik wrote:
> >> The urg_ptr field is not used anywhere and is merely confusing.
> >> 
> > grep -r "urg_ptr" on my linux tree says otherwise.
> 
> I think you're confusing it with tcphdr's field of the same name.
> Petr's patch is correct as far as I can see.

Right, patch applied, thanks everyone.
