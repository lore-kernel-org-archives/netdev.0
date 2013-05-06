From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: frag, fix race conditions in LRU list maintenance
Date: Mon, 06 May 2013 11:08:00 -0400 (EDT)
Message-ID: <20130506.110800.1388239604905052651.davem@davemloft.net>
References: <20130505145622.9351.86587.stgit@zurg>
	<20130506093318.679f5557@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khlebnikov@openvz.org, netdev@vger.kernel.org, edumazet@google.com,
	fw@strlen.de, linux-kernel@vger.kernel.org
To: brouer@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130506093318.679f5557@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 6 May 2013 09:33:18 +0200

> This a good fix, and better than my earlier attempt at fixing this.
 ...
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied, but this patch was generated against a very old tree,
one before the q->net->nqueues stuff was added.

I sorted out the conflicts but someone needs to double-check
my work.
