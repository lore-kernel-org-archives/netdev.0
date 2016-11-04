From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH] virtio-net: drop legacy features in virtio 1 mode
Date: Fri, 4 Nov 2016 12:15:47 +0100
Message-ID: <20161104121547.13cef82f.cornelia.huck@de.ibm.com>
References: <1478256865-29003-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1478256865-29003-1-git-send-email-mst@redhat.com>
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

On Fri, 4 Nov 2016 12:55:36 +0200
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> Virtio 1.0 spec says VIRTIO_F_ANY_LAYOUT and VIRTIO_NET_F_GSO are
> legacy-only feature bits. Do not negotiate them in virtio 1 mode.  Note
> this is a spec violation so we need to backport it to stable/downstream
> kernels.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/virtio_net.c | 30 ++++++++++++++++++++----------
>  1 file changed, 20 insertions(+), 10 deletions(-)

Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
