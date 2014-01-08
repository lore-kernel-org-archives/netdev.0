From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next v2 1/4] net: allow > 0 order atomic page alloc
	in skb_page_frag_refill
Date: Wed, 8 Jan 2014 21:18:03 +0200
Message-ID: <20140108191803.GB18312@redhat.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<20140108180829.GB18162@redhat.com>
	<1389205563.31367.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1389205563.31367.1.camel@edumazet-glaptop2.roam.corp.google.com>
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

On Wed, Jan 08, 2014 at 10:26:03AM -0800, Eric Dumazet wrote:
> On Wed, 2014-01-08 at 20:08 +0200, Michael S. Tsirkin wrote:
> 
> > Eric said we also need a patch to add __GFP_NORETRY, right?
> > Probably before this one in series.
> 
> Nope, this __GFP_NORETRY has nothing to do with this.
> 
> I am not yet convinced we want it.
> 
> This needs mm guys advice, as its a tradeoff for mm layer more than
> networking...

Well maybe Cc linux-mm then?
