From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kmem_cache_alloc panic in 3.10+
Date: Fri, 31 Jan 2014 16:32:00 -0800
Message-ID: <1391214720.28432.88.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.10.1401180036020.18419@dinf>
	 <1390062576.31367.519.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1401181101220.579@dtop>
	 <alpine.DEB.2.02.1401292301070.5905@dtop>
	 <1391134615.28432.83.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQ+vCikFY-te2U8wD+ustNW-o6Cqs8ye5ZfyNcU6vPQzNA@mail.gmail.com>
	 <alpine.DEB.2.10.1401301951060.5516@dinf>
	 <alpine.DEB.2.02.1401311315110.27318@chino.kir.corp.google.com>
	 <alpine.DEB.2.02.1401311407190.17834@dtop>
	 <alpine.DEB.2.02.1401311521170.18890@chino.kir.corp.google.com>
	 <alpine.DEB.2.02.1401311537290.17834@dtop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Rientjes <rientjes@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:36974 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753235AbaBAAcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 19:32:03 -0500
In-Reply-To: <alpine.DEB.2.02.1401311537290.17834@dtop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-31 at 15:43 -0800, dormando wrote:

> chpxchg_double()? that's not related to the 62713c4b fix right?
> 
> I'll see what I can do.. it's going to take a long time to iterate on this
> though.

Dont know about this commit.

I was more thinking about c25f195e828f847735c7626b5693ddc3b853d245
("slub: Check for page NULL before doing the node_match check")
