From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH v2 11/15] virtio_net: enable VQs early
Date: Mon, 6 Oct 2014 17:39:20 +0200
Message-ID: <20141006173920.3e66a421.cornelia.huck@de.ibm.com>
References: <1412608214-31944-1-git-send-email-mst@redhat.com>
	<1412608214-31944-12-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1412608214-31944-12-git-send-email-mst@redhat.com>
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

On Mon, 6 Oct 2014 18:11:19 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> virtio spec requires drivers to set DRIVER_OK before using VQs.
> This is set automatically after probe returns, virtio net violated this
> rule by using receive VQs within probe.
> 
> To fix, call virtio_enable_vqs_early before using VQs.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/virtio_net.c | 2 ++
>  1 file changed, 2 insertions(+)

Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
