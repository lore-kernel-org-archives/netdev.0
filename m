From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: export xfrm garbage collector thresholds via
 sysctl
Date: Mon, 27 Jul 2009 12:40:11 -0700 (PDT)
Message-ID: <20090727.124011.05728493.davem@davemloft.net>
References: <20090727182246.GC15823@hmsreliant.think-freely.org>
	<20090727.113755.260927092.davem@davemloft.net>
	<20090727193625.GD15823@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@nall.com, herbert@gondor.apana.org.au,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52968
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754305AbZG0TkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 15:40:04 -0400
In-Reply-To: <20090727193625.GD15823@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 27 Jul 2009 15:36:25 -0400

> I think that makes sense, since it means we only keep cache entries
> for active connections, and clean them up as soon as they close
> (e.g. I don't really see the advantage to unhashing a xfrm cache
> entry only to recreate it on the next packet sent).

How is this related to the user's problem?

My impression was that they were forwarding IPSEC traffic when
running up against these limits, and that has no socket based
assosciation at all.

Making the XFRM GC limits get computed similarly to how the
ipv4/ipv6 one's do probably makes sense.


