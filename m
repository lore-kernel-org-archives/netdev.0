From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Q/RFC] BPF use in broader scope
Date: Thu, 29 Mar 2012 10:45:32 +0200
Message-ID: <1333010732.2325.339.camel@edumazet-glaptop>
References: <20120329074443.GB2098@minipsycho>
	 <20120329.034957.655153582806618222.davem@davemloft.net>
	 <20120329075410.GC2098@minipsycho>
	 <1333008145.2325.275.camel@edumazet-glaptop>
	 <20120329083149.GD2098@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bhutchings@solarflare.com, shemminger@vyatta.com, matt@ozlabs.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63550 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887Ab2C2Iph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 04:45:37 -0400
Received: by eaaq12 with SMTP id q12so786113eaa.19
        for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 01:45:35 -0700 (PDT)
In-Reply-To: <20120329083149.GD2098@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-03-29 at 10:31 +0200, Jiri Pirko wrote:
> Thu, Mar 29, 2012 at 10:02:25AM CEST, eric.dumazet@gmail.com wrote:
> >On Thu, 2012-03-29 at 09:54 +0200, Jiri Pirko wrote:
> >
> >> Yep, I'm aware. I must admit that the JIT code scares me a litte :(
> >> 
> >
> >If you add a new XOR instruction in interpreter only, JIT compiler will
> >automatically aborts, so no risk.
> >
> >Each arch maintainer will add the support for the new instructions as
> >separate patches.
> >
> >So you can focus on net/core/filter.c file only.
> >
> 
> Ok - I can do this for 2). But for 3) JITs need to be modified. So I
> would like to kindly ask you and Matt if you can do this modification so
> bpf_func takes pointer to mem (scratch store) as second parameter. I'm
> sure it's very easy for you to do.

I am not sure why you want this.

This adds register pressure (at least for x86) ...
