From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] route: Fix caught BUG_ON during
 rt_secret_rebuild_oneshot()
Date: Tue, 16 Mar 2010 14:30:28 -0700 (PDT)
Message-ID: <20100316.143028.54055122.davem@davemloft.net>
References: <20100316173543.GA13529@hmsreliant.think-freely.org>
	<1268762922.2932.3.camel@edumazet-laptop>
	<20100316181816.GC13529@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, vgusev@openvz.org,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48430
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758194Ab0CPVaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 17:30:06 -0400
In-Reply-To: <20100316181816.GC13529@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 16 Mar 2010 14:18:16 -0400

> Ok, I just figured it was time to pose the question, since we'd fixed several
> bugs in this area over the last year.  Certainly doesn't hurt to keep the
> rebuild timer around a bit longer.  I re-iterate my ack to Vitaliy's patch then.

Applied, thanks everyone.

I frankly would be OK with seeing the rebuild timer go away
as early as 2.6.35
