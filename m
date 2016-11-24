From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 1/3] tools/virtio: fix READ_ONCE()
Date: Thu, 24 Nov 2016 12:34:02 +0100
Message-ID: <20161124123402.4b3ef820.cornelia.huck@de.ibm.com>
References: <1479983114-17190-1-git-send-email-mark.rutland@arm.com>
	<1479983114-17190-2-git-send-email-mark.rutland@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dave@stgolabs.net, kvm@vger.kernel.org, dbueso@suse.de,
	netdev@vger.kernel.org, mst@redhat.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	paulmck@linux.vnet.ibm.com, dvyukov@google.com
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1479983114-17190-2-git-send-email-mark.rutland@arm.com>
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

On Thu, 24 Nov 2016 10:25:12 +0000
Mark Rutland <mark.rutland@arm.com> wrote:

> The virtio tools implementation of READ_ONCE() has a single parameter called
> 'var', but erroneously refers to 'val' for its cast, and thus won't work unless
> there's a variable of the correct type that happens to be called 'var'.
> 
> Fix this with s/var/val/, making READ_ONCE() work as expected regardless.
> 
> Fixes: a7c490333df3cff5 ("tools/virtio: use virt_xxx barriers")
> Signed-off-by: Mark Rutland <mark.rutland@arm.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: virtualization@lists.linux-foundation.org
> ---
>  tools/virtio/linux/compiler.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
