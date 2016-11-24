From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 2/3] vringh: kill off ACCESS_ONCE()
Date: Thu, 24 Nov 2016 12:35:46 +0100
Message-ID: <20161124123546.2727086b.cornelia.huck@de.ibm.com>
References: <1479983114-17190-1-git-send-email-mark.rutland@arm.com>
	<1479983114-17190-3-git-send-email-mark.rutland@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dave@stgolabs.net, kvm@vger.kernel.org, dbueso@suse.de,
	netdev@vger.kernel.org, mst@redhat.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	paulmck@linux.vnet.ibm.com, dvyukov@google.com
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1479983114-17190-3-git-send-email-mark.rutland@arm.com>
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

On Thu, 24 Nov 2016 10:25:13 +0000
Mark Rutland <mark.rutland@arm.com> wrote:

> Despite living under drivers/ vringh.c is also used as part of the userspace
> virtio tools. Before we can kill off the ACCESS_ONCE()definition in the tools,
> we must convert vringh.c to use {READ,WRITE}_ONCE().
> 
> This patch does so, along with the required include of <linux/compiler.h> for
> the relevant definitions. The userspace tools provide their own definitions in
> their own <linux/compiler.h>.
> 
> Signed-off-by: Mark Rutland <mark.rutland@arm.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: kvm@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Cc: virtualization@lists.linux-foundation.org
> ---
>  drivers/vhost/vringh.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)

Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
