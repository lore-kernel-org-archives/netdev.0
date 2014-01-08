From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/4] net: allow > 0 order atomic page alloc
	in skb_page_frag_refill
Date: Wed, 08 Jan 2014 10:26:03 -0800
Message-ID: <1389205563.31367.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<20140108180829.GB18162@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20140108180829.GB18162@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-01-08 at 20:08 +0200, Michael S. Tsirkin wrote:

> Eric said we also need a patch to add __GFP_NORETRY, right?
> Probably before this one in series.

Nope, this __GFP_NORETRY has nothing to do with this.

I am not yet convinced we want it.

This needs mm guys advice, as its a tradeoff for mm layer more than
networking...
