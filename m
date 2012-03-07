From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] net/hyperv: Advertise hv_netvsc instead of netvsc as
	driver name
Date: Wed, 7 Mar 2012 11:22:04 -0800
Message-ID: <20120307192204.GA9163@kroah.com>
References: <1331147131-6660-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Olaf Hering <olaf@aepfle.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	davem@davemloft.net
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1331147131-6660-1-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 07, 2012 at 11:05:31AM -0800, Haiyang Zhang wrote:
> From: Olaf Hering <olaf@aepfle.de>
> 
> Signed-off-by: Olaf Hering <olaf@aepfle.de>
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> ---
>  drivers/net/hyperv/netvsc_drv.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index 0ae7a1a..53d1ee5 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -40,6 +40,8 @@
>  
>  #include "hyperv_net.h"
>  
> +#define MODULE_NAME "hv_netvsc"

No, please use the built-in macro for this and don't define your own,
that's totally redundant.

greg k-h
