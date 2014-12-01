From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH v7 27/46] virtio_net: enable v1.0 support
Date: Mon, 1 Dec 2014 12:40:08 +0100
Message-ID: <20141201124008.3d8ca343.cornelia.huck@de.ibm.com>
References: <1417359787-10138-1-git-send-email-mst@redhat.com>
	<1417359787-10138-28-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thuth@linux.vnet.ibm.com, rusty@au1.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	dahi@linux.vnet.ibm.com, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1417359787-10138-28-git-send-email-mst@redhat.com>
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

On Sun, 30 Nov 2014 17:11:30 +0200
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> Now that we have completed 1.0 support, enable it in our driver.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/virtio_net.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index a0e64cf..c6a72d3 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -2003,6 +2003,7 @@ static unsigned int features[] = {
>  	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
>  	VIRTIO_NET_F_CTRL_MAC_ADDR,
>  	VIRTIO_F_ANY_LAYOUT,
> +	VIRTIO_F_VERSION_1,
>  };
> 
>  static struct virtio_driver virtio_net_driver = {

Shouldn't you move this after the patch disabling mac address writing?
