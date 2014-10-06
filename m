From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH v2 07/15] virtio_net: drop config_enable
Date: Mon, 6 Oct 2014 17:28:01 +0200
Message-ID: <20141006172801.1f2e520e.cornelia.huck@de.ibm.com>
References: <1412608214-31944-1-git-send-email-mst@redhat.com>
	<1412608214-31944-8-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1412608214-31944-8-git-send-email-mst@redhat.com>
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

On Mon, 6 Oct 2014 18:11:05 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> Now that virtio core ensures config changes don't arrive during probing,
> drop config_enable flag in virtio net.
> On removal, flush is now sufficient to guarantee that no change work is
> queued.
> 
> This help simplify the driver, and will allow setting DRIVER_OK earlier
> without losing config change notifications.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/virtio_net.c | 27 ++++-----------------------
>  1 file changed, 4 insertions(+), 23 deletions(-)

Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
