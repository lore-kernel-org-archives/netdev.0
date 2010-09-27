From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v11 11/17] Add header file for mp device.
Date: Mon, 27 Sep 2010 14:55:15 +0100
Message-ID: <1285595715.2263.12.camel@achroite.uk.solarflarecom.com>
References: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
	 <924a3a20630b9b0b7f3c66633c792360bbcc790d.1285385607.git.xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28203 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865Ab0I0NzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 09:55:19 -0400
In-Reply-To: <924a3a20630b9b0b7f3c66633c792360bbcc790d.1285385607.git.xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-09-25 at 12:27 +0800, xiaohui.xin@intel.com wrote:
> From: Xin Xiaohui <xiaohui.xin@intel.com>
> 
> Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
> Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
> Reviewed-by: Jeff Dike <jdike@linux.intel.com>
> ---
>  include/linux/mpassthru.h |   25 +++++++++++++++++++++++++
>  1 files changed, 25 insertions(+), 0 deletions(-)
>  create mode 100644 include/linux/mpassthru.h
> 
> diff --git a/include/linux/mpassthru.h b/include/linux/mpassthru.h
> new file mode 100644
> index 0000000..ba8f320
> --- /dev/null
> +++ b/include/linux/mpassthru.h
> @@ -0,0 +1,25 @@
> +#ifndef __MPASSTHRU_H
> +#define __MPASSTHRU_H
> +
> +#include <linux/types.h>
> +#include <linux/if_ether.h>
> +
> +/* ioctl defines */
> +#define MPASSTHRU_BINDDEV      _IOW('M', 213, int)
> +#define MPASSTHRU_UNBINDDEV    _IO('M', 214)
[...]

You need to include <linux/ioctl.h> first!

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

