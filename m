From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 02/39] mv643xx_eth: trim unnecessary includes
Date: Thu, 5 Jun 2008 04:02:52 -0700
Message-ID: <20080605110252.GA1059@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-3-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:44781 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755482AbYFELl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:41:27 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-3-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:17PM +0200, Lennert Buytenhek wrote:
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   18 +-----------------
>  1 files changed, 1 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> index 835b85d..c04058c 100644
> --- a/drivers/net/mv643xx_eth.c
> +++ b/drivers/net/mv643xx_eth.c
> @@ -34,34 +34,18 @@
>   * along with this program; if not, write to the Free Software
>   * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
>   */
> -#include <linux/init.h>
> -#include <linux/dma-mapping.h>
> +
>  #include <linux/in.h>
> -#include <linux/ip.h>
>  #include <linux/tcp.h>
>  #include <linux/udp.h>
>  #include <linux/etherdevice.h>
> -
> -#include <linux/bitops.h>
> -#include <linux/delay.h>
>  #include <linux/ethtool.h>
>  #include <linux/platform_device.h>
> -
>  #include <linux/module.h>
> -#include <linux/kernel.h>
>  #include <linux/spinlock.h>
> -#include <linux/workqueue.h>

Isn't this needed for the definition of struct work and schedule_work()?

>  #include <linux/mii.h>
> -
>  #include <linux/mv643xx_eth.h>
>  
> -#include <asm/io.h>
> -#include <asm/types.h>
> -#include <asm/pgtable.h>
> -#include <asm/system.h>
> -#include <asm/delay.h>

Don't we still need this for udelay()?
> -#include <asm/dma-mapping.h>

And this for dma_map_single, etc.

I didn't bother to check all the other includes being removed, but it
seems you may have been a bit overly aggressive.

-Dale
