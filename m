From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] virtio-net: validate features during probe
Date: Wed, 19 Nov 2014 15:07:17 +0800
Message-ID: <546C41A5.6090306@redhat.com>
References: <1416378939-28821-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1416378939-28821-1-git-send-email-jasowang@redhat.com>
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

On 11/19/2014 02:35 PM, Jason Wang wrote:
> This patch validates feature dependencies during probe and fail the probing
> if a dependency is missed. This fixes the issues of hitting BUG()
> when qemu fails to advertise features correctly. One example is booting
> guest with ctrl_vq=off through qemu.
>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
> Cc: Wanlong Gao <gaowanlong@cn.fujitsu.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---

Just notice UFO has been disabled after
3d0ad09412ffe00c9afa201d01effdb6023d09b4 "drivers/net: Disable UFO
through virtio". Will post V2 and drop VIRTIO_NET_F_*_UFO from the
checklist.
