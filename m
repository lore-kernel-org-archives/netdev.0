From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 1/2] net: introduce skb_coalesce_rx_frag()
Date: Mon, 04 Nov 2013 20:04:22 -0500 (EST)
Message-ID: <20131104.200422.1529242936573745110.davem@davemloft.net>
References: <1383286068-10421-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mwdalton@google.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kmindg@gmail.com,
	edumazet@google.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1383286068-10421-1-git-send-email-jasowang@redhat.com>
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

From: Jason Wang <jasowang@redhat.com>
Date: Fri,  1 Nov 2013 14:07:47 +0800

> Sometimes we need to coalesce the rx frags to avoid frag list. One example is
> virtio-net driver which tries to use small frags for both MTU sized packet and
> GSO packet. So this patch introduce skb_coalesce_rx_frag() to do this.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michael Dalton <mwdalton@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> Changes from V2:
> - remove the skb_frag_unref() and let the called to put the page reference
> Changes from V1:
> - remove the useless off parameter.

Applied.
