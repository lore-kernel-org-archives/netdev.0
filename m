From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/5] davinci: net: cpdma: remove unwanted header file
 incusion and sort thme alphabetically
Date: Thu, 16 May 2013 22:53:12 +0400
Message-ID: <51952B18.4060004@cogentembedded.com>
References: <1368689438-23889-1-git-send-email-prabhakar.csengg@gmail.com> <1368689438-23889-2-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <trivial@kernel.org>, netdev@vger.kernel.org,
	Mugunthan V N <mugunthanvnm@ti.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Lad Prabhakar <prabhakar.csengg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368689438-23889-2-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 16-05-2013 11:30, Lad Prabhakar wrote:

    s/incusion/inclusion/, s/thme/them/ in the subject. Though instead 
of "them" it would be better to write "headers".

> From: Lad, Prabhakar <prabhakar.csengg@gmail.com>

    Changelog won't hurt here... which unwanted #include's you are 
removing and why are they unwanted?

> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
> ---
>   drivers/net/ethernet/ti/davinci_cpdma.c |   10 +++-------
>   1 files changed, 3 insertions(+), 7 deletions(-)

> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
> index 49dfd59..f7ce97f 100644
> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
> @@ -12,15 +12,11 @@
>    * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>    * GNU General Public License for more details.
>    */
> -#include <linux/kernel.h>
> -#include <linux/spinlock.h>
> -#include <linux/device.h>
> +
> +#include <linux/delay.h>
> +#include <linux/dma-mapping.h>
>   #include <linux/module.h>
>   #include <linux/slab.h>
> -#include <linux/err.h>
> -#include <linux/dma-mapping.h>
> -#include <linux/io.h>
> -#include <linux/delay.h>
>
>   #include "davinci_cpdma.h"

WBR, Sergei
