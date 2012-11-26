From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next] net: clean up locking in inet_frag_find()
Date: Mon, 26 Nov 2012 13:53:04 +0800
Message-ID: <1353909184.11282.3.camel@cr0>
References: <1353907085-30824-1-git-send-email-amwang@redhat.com>
	 <1353908592.30446.1136.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6964 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751319Ab2KZFyE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2012 00:54:04 -0500
In-Reply-To: <1353908592.30446.1136.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-11-25 at 21:43 -0800, Eric Dumazet wrote:
> On Mon, 2012-11-26 at 13:18 +0800, Cong Wang wrote:
> > It is weird to take the read lock outside of inet_frag_find()
> > but release it inside... Also, the hash function doesn't
> > need this lock.
> 
> This patch is wrong. hash needs the lock.
> 
> 

Indeed, I missed .rnd...

I am cooking a better patch now.

Thanks!
