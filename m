From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
 gc_elasticity is exceeded
Date: Tue, 30 Sep 2008 07:08:49 -0700 (PDT)
Message-ID: <20080930.070849.257248719.davem@davemloft.net>
References: <20080929191254.GA20074@hmsreliant.think-freely.org>
	<48E138EB.1080001@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60277
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753584AbYI3OJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 10:09:00 -0400
In-Reply-To: <48E138EB.1080001@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 29 Sep 2008 22:22:03 +0200

> This sounds not good at all to me.
> 
> 1) Dont set ip_rt_secret_interval to zero, this is plain silly, since
>    you give attackers infinite time to break your machine.
> 

It makes a ton of sense, even by default, if we set things up so that
we turn it back on when necessary.

And that's the final intended idea, to do exactly that.
