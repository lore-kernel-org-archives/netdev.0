From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v6 33/46] vhost/net: larger header for virtio 1.0
Date: Fri, 28 Nov 2014 08:46:14 +0008
Message-ID: <1417163894.5822.10@smtp.corp.redhat.com>
References: <1417118789-18231-1-git-send-email-mst@redhat.com>
	<1417118789-18231-34-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: thuth@linux.vnet.ibm.com, kvm@vger.kernel.org, rusty@au1.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	dahi@linux.vnet.ibm.com, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1417118789-18231-34-git-send-email-mst@redhat.com>
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



On Fri, Nov 28, 2014 at 4:10 AM, Michael S. Tsirkin <mst@redhat.com> 
wrote:
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/vhost/net.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index cae22f9..1ac58d0 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -1027,7 +1027,8 @@ static int vhost_net_set_features(struct 
> vhost_net *n, u64 features)
>  	size_t vhost_hlen, sock_hlen, hdr_len;
>  	int i;
>  
> -	hdr_len = (features & (1 << VIRTIO_NET_F_MRG_RXBUF)) ?
> +	hdr_len = (features & ((1ULL << VIRTIO_NET_F_MRG_RXBUF) |
> +			       (1ULL << VIRTIO_F_VERSION_1))) ?
>  			sizeof(struct virtio_net_hdr_mrg_rxbuf) :
>  			sizeof(struct virtio_net_hdr);
>  	if (features & (1 << VHOST_NET_F_VIRTIO_NET_HDR)) {
> -- 
> MST
> 

Reviewed-by: Jason Wang <jasowang@redhat.com>
