From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH] dynamic_queue_limit.h: Make the struct
 ___cacheline_aligned_on_smp
Date: Fri, 07 Dec 2012 08:29:21 -0800
Message-ID: <1354897761.29937.45.camel@joe-AO722>
References: <1354892334.29937.14.camel@joe-AO722>
	 <CAL4Wiip12_Frb64WGk419_YApOuckTa3Jtd-nVROodLFTqvacg@mail.gmail.com>
	 <1354896346.29937.43.camel@joe-AO722>
	 <1354897144.26405.4.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:40361 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1422762Ab2LGQ3V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 11:29:21 -0500
In-Reply-To: <1354897144.26405.4.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-07 at 08:19 -0800, Eric Dumazet wrote:
> On Fri, 2012-12-07 at 08:05 -0800, Joe Perches wrote:
> 
> > So it seemed somewhat sensible to make the
> > entire struct in a single cacheline.
> 
> Any layout change in an object used in network fast path need a complete
> performance study.
> 
> Even if you provide such a study, we'll need to reproduce your numbers
> here.
> 
> BQL/DQL is not on our radars, spending two cache lines on a critical
> object is fine.

Well Maybe Tom can provide some information as to why
the limit variable was cacheline_aligned_in_smp and not
the struct.

I didn't find any discussion about it.
