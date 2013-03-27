From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/3] net: use the frag lru_lock to protect
 netns_frags.nqueues update
Date: Wed, 27 Mar 2013 09:21:48 -0700
Message-ID: <1364401308.15753.23.camel@edumazet-glaptop>
References: <20130327155238.15203.6688.stgit@dragon>
	 <20130327155530.15203.45784.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f180.google.com ([209.85.210.180]:56806 "EHLO
	mail-ia0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143Ab3C0QVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 12:21:50 -0400
Received: by mail-ia0-f180.google.com with SMTP id f27so7380070iae.25
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 09:21:50 -0700 (PDT)
In-Reply-To: <20130327155530.15203.45784.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-27 at 16:55 +0100, Jesper Dangaard Brouer wrote:
> Move the protection of netns_frags.nqueues updates under the LRU_lock,
> instead of the write lock.  As they are located on the same cacheline,
> and this is also needed when transitioning to use per hash bucket locking.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
