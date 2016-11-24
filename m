From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 3/3] tools/virtio: use {READ,WRITE}_ONCE() in uaccess.h
Date: Thu, 24 Nov 2016 12:37:52 +0100
Message-ID: <20161124123752.5b1a3561.cornelia.huck@de.ibm.com>
References: <1479983114-17190-1-git-send-email-mark.rutland@arm.com>
	<1479983114-17190-4-git-send-email-mark.rutland@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dave@stgolabs.net, kvm@vger.kernel.org, dbueso@suse.de,
	netdev@vger.kernel.org, mst@redhat.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	paulmck@linux.vnet.ibm.com, dvyukov@google.com
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1479983114-17190-4-git-send-email-mark.rutland@arm.com>
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

On Thu, 24 Nov 2016 10:25:14 +0000
Mark Rutland <mark.rutland@arm.com> wrote:

> As a step towards killing off ACCESS_ONCE, use {READ,WRITE}_ONCE() for the
> virtio tools uaccess primitives, pulling these in from <linux/compiler.h>.
> 
> With this done, we can kill off the now-unused ACCESS_ONCE() definition.
> 
> Signed-off-by: Mark Rutland <mark.rutland@arm.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: virtualization@lists.linux-foundation.org
> ---
>  tools/virtio/linux/uaccess.h | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)

Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
