From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/1] netvsc: Add #include's for csum_* function
 declarations
Date: Tue, 30 May 2017 11:03:21 -0700
Message-ID: <1496167401.2618.27.camel@perches.com>
References: <1496166184-19805-1-git-send-email-mikelley@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mikelley@microsoft.com, davem@davemloft.net, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de,
 apw@canonical.com, jasowang@redhat.com, leann.ogasawara@canonical.comi,
 marcelo.cerri@canonical.com, sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1496166184-19805-1-git-send-email-mikelley@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Tue, 2017-05-30 at 10:43 -0700, Michael Kelley wrote:
> Add direct #include statements for declarations of csum_tcpudp_magic()
> and csum_ipv6_magic(). While the needed #include's are picked up
> indirectly for the x86 architecture, they aren't on other
> architectures, resulting in compile errors.
[]
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index 4421a6d..ca952b3 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -37,6 +37,8 @@
>  #include <net/route.h>
>  #include <net/sock.h>
>  #include <net/pkt_sched.h>
> +#include <asm/checksum.h>

Maybe
#include <net/checksum.h>
instead?

> +#include <net/ip6_checksum.h>
>  
>  #include "hyperv_net.h"
>  
