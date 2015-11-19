From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Thu, 19 Nov 2015 22:44:16 +0100
Message-ID: <20151119214416.GB30304@electric-eye.fr.zoreil.com>
References: <20130309064647.GC4984@marvin.atrad.com.au>
 <20130311000216.GA31808@zoreil.com>
 <20130405001526.GC19253@marvin.atrad.com.au>
 <20151117015605.GI22941@marvin.atrad.com.au>
 <20151117232108.GC3362@electric-eye.fr.zoreil.com>
 <20151118050919.GR25216@marvin.atrad.com.au>
 <20151119005608.GB4882@electric-eye.fr.zoreil.com>
 <20151119065718.GT8170@marvin.atrad.com.au>
 <1447935754.22599.194.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonathan Woithe <jwoithe@atrad.com.au>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58857 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbbKSVoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 16:44:25 -0500
Content-Disposition: inline
In-Reply-To: <1447935754.22599.194.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
[...]
> This looks like a race when/if RX happens very shortly after one
> transmit.
> 
> Francois, are we really saving lot of cpu cycles testing status ?

I'm not sure. An extra smp_rmb and three cache lines at most when
there really isn't any work ? Probably not worth it.

Can you clarify which kind of race you're thinking about ?

-- 
Ueimor
