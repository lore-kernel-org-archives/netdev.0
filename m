From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH] dynamic_queue_limit.h: Make the struct
 ___cacheline_aligned_on_smp
Date: Fri, 7 Dec 2012 16:42:10 +0000
Message-ID: <1354898530.2707.21.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354892334.29937.14.camel@joe-AO722>
	 <CAL4Wiip12_Frb64WGk419_YApOuckTa3Jtd-nVROodLFTqvacg@mail.gmail.com>
	 <1354896346.29937.43.camel@joe-AO722>
	 <1354897144.26405.4.camel@edumazet-glaptop>
	 <1354897761.29937.45.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26999 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422760Ab2LGQmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 11:42:14 -0500
In-Reply-To: <1354897761.29937.45.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-07 at 08:29 -0800, Joe Perches wrote:
> On Fri, 2012-12-07 at 08:19 -0800, Eric Dumazet wrote:
> > On Fri, 2012-12-07 at 08:05 -0800, Joe Perches wrote:
> > 
> > > So it seemed somewhat sensible to make the
> > > entire struct in a single cacheline.
> > 
> > Any layout change in an object used in network fast path need a complete
> > performance study.
> > 
> > Even if you provide such a study, we'll need to reproduce your numbers
> > here.
> > 
> > BQL/DQL is not on our radars, spending two cache lines on a critical
> > object is fine.
> 
> Well Maybe Tom can provide some information as to why
> the limit variable was cacheline_aligned_in_smp and not
> the struct.
> 
> I didn't find any discussion about it.

Structure alignment has to be at least the maximum of each member's
alignment, so the struct *is* effectively cacheline_aligned_in_smp.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
