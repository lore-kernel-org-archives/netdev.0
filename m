From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 1/4] Revert "inet: limit length of fragment
 queue hash table bucket lists"
Date: Thu, 2 May 2013 09:59:55 +0200
Message-ID: <20130502095955.1ea082fb@redhat.com>
References: <20130424154624.16883.40974.stgit@dragon>
	<20130424154800.16883.4797.stgit@dragon>
	<1366848030.8964.98.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47179 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755572Ab3EBIAc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 May 2013 04:00:32 -0400
In-Reply-To: <1366848030.8964.98.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Apr 2013 17:00:30 -0700 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2013-04-24 at 17:48 +0200, Jesper Dangaard Brouer wrote:
> > This reverts commit 5a3da1fe9561828d0ca7eca664b16ec2b9bf0055.
> > 
> > The problem with commit 5a3da1fe (inet: limit length of fragment
> > queue hash table bucket lists) is that, once we hit the hash depth
> > limit (of 128), the we *keep* the existing frag queues, not
> > allowing new frag queues to be created.  Thus, an attacker can
> > effectivly block handling of fragments for 30 sec (as each frag
> > queue have a timeout of 30 sec)
> > 
> 
> I do not think its good to revert this patch. It was a step in right
> direction.

We need a revert, because we are too close to the merge window, and
cannot complete the needed "steps" to make this patch safe, sorry.

--Jesper
