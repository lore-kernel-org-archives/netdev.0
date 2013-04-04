From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V3] net: frag queue per hash bucket locking
Date: Thu, 04 Apr 2013 09:24:15 -0700
Message-ID: <1365092655.3308.10.camel@edumazet-glaptop>
References: <1365067672.12728.46.camel@localhost>
	 <20130404093816.3613.42475.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:53047 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760835Ab3DDQYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 12:24:18 -0400
Received: by mail-pd0-f180.google.com with SMTP id q11so1517465pdj.39
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 09:24:17 -0700 (PDT)
In-Reply-To: <20130404093816.3613.42475.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-04 at 11:38 +0200, Jesper Dangaard Brouer wrote:
> This patch implements per hash bucket locking for the frag queue
> hash.  This removes two write locks, and the only remaining write
> lock is for protecting hash rebuild.  This essentially reduce the
> readers-writer lock to a rebuild lock.

Acked-by: Eric Dumazet <edumazet@google.com>
