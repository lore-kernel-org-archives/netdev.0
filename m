From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/4] virtio-net: use per-receive queue page
	frag alloc for mergeable bufs
Date: Tue, 12 Nov 2013 14:43:47 -0800
Message-ID: <1384296227.28458.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384294885-6444-1-git-send-email-mwdalton@google.com>
	<1384294885-6444-3-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1384294885-6444-3-git-send-email-mwdalton@google.com>
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

On Tue, 2013-11-12 at 14:21 -0800, Michael Dalton wrote:
> The virtio-net driver currently uses netdev_alloc_frag() for GFP_ATOMIC
> mergeable rx buffer allocations. This commit migrates virtio-net to use
> per-receive queue page frags for GFP_ATOMIC allocation. This change unifies
> mergeable rx buffer memory allocation, which now will use skb_refill_frag()
> for both atomic and GFP-WAIT buffer allocations.
> 
> To address fragmentation concerns, if after buffer allocation there
> is too little space left in the page frag to allocate a subsequent
> buffer, the remaining space is added to the current allocated buffer
> so that the remaining space can be used to store packet data.
> 
> Signed-off-by: Michael Dalton <mwdalton@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
