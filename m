From: David Miller <davem@davemloft.net>
Subject: Re: [RFC patch net/next] net: Hoist assigns from if?
Date: Mon, 14 Jun 2010 22:59:10 -0700 (PDT)
Message-ID: <20100614.225910.104075511.davem@davemloft.net>
References: <1276561234.4897.38.camel@Joe-Laptop.home>
	<1276580526.30434.330.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46348
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750874Ab0FOF7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 01:59:00 -0400
In-Reply-To: <1276580526.30434.330.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Jun 2010 07:42:06 +0200

> Quite honestly, this kind of patch sucks, because it pollutes 'git
> blame' output. Its hard to point out the origin of a particular
> bug/code, and we have to spend precious time playing with complex git
> commands to go over cleanup patches.

I have to agree with Eric on this.

Pundits of these changes will argue that this is a deficiency in
git itself.

But that to me just means that until git has a friendlier way to
walk backwards through blame information for a line to skip past
the cleanup crapola, we shouldn't make a lot of these kinds of
changes.

So that means I'm really not excited to see this kind of patch
submitted, it's just noise that hurts scanning through history
and thus hurts development.
