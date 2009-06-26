From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Fri, 26 Jun 2009 09:37:27 +0000
Message-ID: <20090626093727.GA6832@ff.dom.local>
References: <4A43E9F1.90209@cosmosbay.com> <20090626080302.GB5204@ff.dom.local> <19012.37515.146191.198843@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	=?us-ascii?B?PT9JU08tODg1OS0yP1E/UGF3ZT1CM19TdGFzemV3c2tpPz0=?=
	<pstaszewski@itcare.pl>, Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:42404 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306AbZFZJha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 05:37:30 -0400
Received: by fxm9 with SMTP id 9so1979181fxm.37
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2009 02:37:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <19012.37515.146191.198843@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2009 at 11:19:07AM +0200, Robert Olsson wrote:
> 
> Jarek Poplawski writes:
> 
>  > >> oprofile: using NMI interrupt.
>  > >> Fix inflate_threshold_root. Now=15 size=11 bits
>  > >> Fix inflate_threshold_root. Now=15 size=11 bits
>  > >> Fix inflate_threshold_root. Now=15 size=11 bits
>  > >> Fix inflate_threshold_root. Now=15 size=11 bits
>  > >> Fix inflate_threshold_root. Now=15 size=11 bits
>  > >> Fix inflate_threshold_root. Now=15 size=11 bits
> 
>  > On the other hand, even if there is no problem with memory, it seems
>  > because of hitting max_resize the threshold should be changed, e.g.
>  > by reverting the patch below.
> 
>  You seem to have some temporary memory problem. So the printout might be
>  a bit misleading in this case. We really like to keep the root node as big 
>  as we can to keep the tree as flat as possible for performance reasons.
>  (We're even more motivated now when we can disable the route cache)
> 
>  So I'll guess the next insert/delete inflates the root node to be within
>  the interval. So I'll assume this just a temporary failure?
> 
>  I would be nice to have *threshholds* settable by /proc or /sys. I would
>  use this in the other direction to trade memory for even faster lookups. 
>  
>  But maybe experts memory allocation has some good suggestions.
> 

Pawel has reported these problems for a long time:
http://bugzilla.kernel.org/show_bug.cgi?id=6648

So, until it's fully investigated, it seems some 'fast' fix is needed
here.

Cheers,
Jarek P.
