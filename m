From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [2.6.19 PATCH 5/7] ehea: main header files
Date: Fri, 18 Aug 2006 18:16:00 +0400
Message-ID: <20060818141600.GD5201@martell.zuzino.mipt.ru>
References: <200608181334.57701.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <tklein@de.ibm.com>, Jan-Bernd Themann <themann@de.ibm.com>,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>,
	Thomas Klein <osstklei@de.ibm.com>, linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>, Marcus Eder <meder@de.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <200608181334.57701.ossthema@de.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 18, 2006 at 01:34:57PM +0200, Jan-Bernd Themann wrote:
> --- linux-2.6.18-rc4-orig/drivers/net/ehea/ehea.h
> +++ kernel/drivers/net/ehea/ehea.h

> +#include <linux/version.h>

Not needed.

> +#include <linux/module.h>
> +#include <linux/moduleparam.h>

Really?

> +#include <linux/kernel.h>
> +#include <linux/vmalloc.h>
> +#include <linux/mm.h>
> +#include <linux/slab.h>
> +#include <linux/sched.h>
> +#include <linux/err.h>
> +#include <linux/list.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/kthread.h>

Nothing is used here. grep kthread

> +#include <linux/ethtool.h>
> +#include <linux/if_vlan.h>

It this because of "struct vlan_group" just add "struct vlan_group;" at
the beginning of the headers.

> +#include <asm/ibmebus.h>
> +#include <asm/of_device.h>
> +#include <asm/abs_addr.h>
> +#include <asm/semaphore.h>
> +#include <asm/current.h>
> +#include <asm/io.h>

Please, use only headers you only really need. Full rebuilds are already pretty
enough. I've included half of include/linux disaster must stop.
