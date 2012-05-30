From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 0/2] Faster/parallel SYN handling to mitigate SYN
 floods
Date: Wed, 30 May 2012 10:50:24 +0200
Message-ID: <1338367824.2760.128.camel@edumazet-glaptop>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
	 <4FC3A465.4030203@uclouvain.be> <1338322661.7747.17.camel@localhost>
	 <4FC53353.2050801@uclouvain.be>  <1338367497.7747.72.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	opurdila@ixiacom.com,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Andi Kleen <andi@firstfloor.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58375 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932264Ab2E3Iu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 04:50:29 -0400
Received: by bkcji2 with SMTP id ji2so3868764bkc.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 01:50:28 -0700 (PDT)
In-Reply-To: <1338367497.7747.72.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 10:44 +0200, Jesper Dangaard Brouer wrote:

> Choosing that code path, should be easy by simply returning 0 (no_limit)
> from my function tcp_v4_syn_conn_limit(), to indicate that the normal
> slow code path should be chosen.
> 
> I guess this will not pose a big attack angle, as the entries in
> reqsk_queue will be fairly small.

Not sure what you mean.

I know some people have 64K entries in it.

(sk_ack_backlog / sk_max_ack_backlog being 16bits, 
listen(fd, 65536 + 1) can give unexpected results)
