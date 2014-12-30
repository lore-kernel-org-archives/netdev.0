From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] virtio-net: don't do header check for
	dodgy gso packets
Date: Tue, 30 Dec 2014 18:53:50 -0500 (EST)
Message-ID: <20141230.185350.1886821773938320675.davem@davemloft.net>
References: <1419390232-14906-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1419390232-14906-1-git-send-email-jasowang@redhat.com>
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
Date: Wed, 24 Dec 2014 11:03:52 +0800

> There's no need to do header check for virtio-net since:
> 
> - Host sets dodgy for all gso packets from guest and check the header.
> - Host should be prepared for all kinds of evil packets from guest, since
>   malicious guest can send any kinds of packet.
> 
> So this patch sets NETIF_F_GSO_ROBUST for virtio-net to skip the check.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> Changes from V1:
> - typo fixes

Applied.
