From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH -next] gianfar: Fix build with CONFIG_PM enabled
Date: Thu, 19 Mar 2009 10:16:26 -0500
Message-ID: <DA082A7B-8C8A-47A9-9B50-143AF6A27F18@kernel.crashing.org>
References: <20090319151217.GA11465@oksana.dev.rtsoft.ru>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090319151217.GA11465@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Mar 19, 2009, at 10:12 AM, Anton Vorontsov wrote:

> commit 4826857f1bf07f9c0f1495e9b05d125552c88a85 ("gianfar: pass the
> proper dev to DMA ops") introduced this build breakage:
>
>  CC      drivers/net/gianfar.o
> drivers/net/gianfar.c: In function 'gfar_suspend':
> drivers/net/gianfar.c:552: error: 'struct gfar_private' has no  
> member named 'dev'
> drivers/net/gianfar.c: In function 'gfar_resume':
> drivers/net/gianfar.c:601: error: 'struct gfar_private' has no  
> member named 'dev'
> make[2]: *** [drivers/net/gianfar.o] Error 1
>
> Fix this by converting suspend and resume routines to use
> gfar_private->ndev.
>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
> drivers/net/gianfar.c |    4 ++--
> 1 files changed, 2 insertions(+), 2 deletions(-)

Acked-by: Kumar Gala <galak@kernel.crashing.org>

- k
