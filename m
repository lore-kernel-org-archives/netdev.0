From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 2/2] tcp: Early SYN limit and SYN cookie handling
 to mitigate SYN floods
Date: Wed, 30 May 2012 11:46:05 +0200
Message-ID: <1338371165.2760.133.camel@edumazet-glaptop>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
	 <20120528115226.12068.31850.stgit@localhost.localdomain>
	 <m2bol6lqxo.fsf@firstfloor.org> <1338360073.2760.81.camel@edumazet-glaptop>
	 <1338363926.7747.55.camel@localhost>
	 <1338365702.2760.112.camel@edumazet-glaptop>
	 <1338369863.7747.96.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47563 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138Ab2E3JqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 05:46:12 -0400
Received: by bkcji2 with SMTP id ji2so3914456bkc.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 02:46:10 -0700 (PDT)
In-Reply-To: <1338369863.7747.96.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 11:24 +0200, Jesper Dangaard Brouer wrote:

> I don't dare to go into that battle with the network ninja, I surrender.
> DaveM, Eric's patches take precedence over mine...
> 
> /me Crawing back into my cave, and switching to boring bugzilla cases of
> backporting kernel patches instead...
> 

Hey, I only wanted to say that we were working on the same area and that
we should expect conflicts.

In the long term, we want a scalable listener solution, but I can
understand if some customers want an immediate solution (SYN flood
mitigation)
