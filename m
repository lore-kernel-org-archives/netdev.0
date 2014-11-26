From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH v4 20/42] virtio_net: pass vi around
Date: Wed, 26 Nov 2014 13:35:24 +0100
Message-ID: <20141126133524.27e9beb6.cornelia.huck@de.ibm.com>
References: <1416933600-21398-1-git-send-email-mst@redhat.com>
	<1416933600-21398-21-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rusty@au1.ibm.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1416933600-21398-21-git-send-email-mst@redhat.com>
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

On Tue, 25 Nov 2014 18:42:49 +0200
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> Too many places poke at [rs]q->vq->vdev->priv just to get
> the the vi structure.  Let's just pass the pointer around: seems

s/the the/the/

> cleaner, and might even be faster.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/virtio_net.c | 38 ++++++++++++++++++++------------------
>  1 file changed, 20 insertions(+), 18 deletions(-)
> 
Looks reasonable.

Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
