From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 2/2] vhost: disentangle vring endianness stuff from the
	core code
Date: Thu, 21 Jan 2016 10:56:07 +0100
Message-ID: <20160121105607.373ce75a.cornelia.huck@de.ibm.com>
References: <20160113170934.23705.62626.stgit@bahia.huguette.org>
	<20160113170947.23705.95216.stgit@bahia.huguette.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Greg Kurz <gkurz@linux.vnet.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160113170947.23705.95216.stgit@bahia.huguette.org>
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

On Wed, 13 Jan 2016 18:09:47 +0100
Greg Kurz <gkurz@linux.vnet.ibm.com> wrote:

> The way vring endianness is being handled currently obfuscates
> the code in vhost_init_used().
> 
> This patch tries to fix that by doing the following:
> - move the the code that adjusts endianness to a dedicated helper
> - export this helper so that backends explicitely call it
> 
> No behaviour change.
> 
> Signed-off-by: Greg Kurz <gkurz@linux.vnet.ibm.com>
> ---
>  drivers/vhost/net.c   |    3 +++
>  drivers/vhost/scsi.c  |    3 +++
>  drivers/vhost/test.c  |    2 ++
>  drivers/vhost/vhost.c |   16 +++++++++++-----
>  drivers/vhost/vhost.h |    1 +
>  5 files changed, 20 insertions(+), 5 deletions(-)

Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
