From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH v16 14/17]Add a kconfig entry and make entry for mp
 device.
Date: Wed, 1 Dec 2010 09:53:48 -0800
Message-ID: <20101201095348.07421ee5.randy.dunlap@oracle.com>
References: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1291187695.git.xiaohui.xin@intel.com>
	<a1c255bc496b7aaca26912790f8bb0162dd1f4bf.1291187695.git.xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.hengli.com.au,
	jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a1c255bc496b7aaca26912790f8bb0162dd1f4bf.1291187695.git.xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed,  1 Dec 2010 16:08:25 +0800 xiaohui.xin@intel.com wrote:

> From: Xin Xiaohui <xiaohui.xin@intel.com>
> 
> Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
> Reviewed-by: Jeff Dike <jdike@linux.intel.com>
> ---
>  drivers/vhost/Kconfig  |   10 ++++++++++
>  drivers/vhost/Makefile |    2 ++
>  2 files changed, 12 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
> index e4e2fd1..a6b8cbf 100644
> --- a/drivers/vhost/Kconfig
> +++ b/drivers/vhost/Kconfig
> @@ -9,3 +9,13 @@ config VHOST_NET
>  	  To compile this driver as a module, choose M here: the module will
>  	  be called vhost_net.
>  
> +config MEDIATE_PASSTHRU
> +	tristate "mediate passthru network driver (EXPERIMENTAL)"
> +	depends on VHOST_NET
> +	---help---
> +	  zerocopy network I/O support, we call it as mediate passthru to

	                       support; we call it "mediate passthru" to

> +	  be distiguish with hardare passthru.

	  distinguish it from hardware passthru.

> +
> +	  To compile this driver as a module, choose M here: the module will
> +	  be called mpassthru.
> +


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
