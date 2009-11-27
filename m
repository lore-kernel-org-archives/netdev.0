From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Fri, 27 Nov 2009 09:26:57 +0100
Message-ID: <1259310417.3809.5.camel@nienna.balabit>
References: <db81a9a20911230443h443b3c2l8fab5aef7b09cfa@mail.gmail.com>
	 <1259137434.9191.3.camel@nienna.balabit>
	 <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tproxy@lists.balabit.hu, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Andreas Schultz <aschultz@warp10.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:40361 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750952AbZK0I0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Nov 2009 03:26:53 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 5C31811E1AE
	for <netdev@vger.kernel.org>; Fri, 27 Nov 2009 09:26:58 +0100 (CET)
In-Reply-To: <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, 2009-11-26 at 18:19 +0100, Andreas Schultz wrote:
> Hi,
> 
> git bisect shows that TPROXY has been broken by commit
> f7c6fd2465d8e6f4f89c5d1262da10b4a6d499d0, [PATCH] net: Fix RPF to work
> with policy routing
> 
> I had a look at the patch, and it seems logical that this would break TPROXY.

Indeed, that's a good catch. If this is indeed the problem you should be
able to work it around by disabling rpfilter on the ingress interface.
Does it work that way?

Cheers,
Krisztian


