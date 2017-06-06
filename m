From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 3/4] net: macb: macb.c changed to macb_main.c
Date: Tue, 6 Jun 2017 20:39:33 +0200
Message-ID: <20170606183933.GA1205@localhost.localdomain>
References: <1496413439-12900-1-git-send-email-rafalo@cadence.com>
 <1496413661-21452-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org, nicolas.ferre@atmel.com,
 linux-kernel@vger.kernel.org, andrei.pistirica@microchip.com,
 harini.katakam@xilinx.com, David Miller <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org
To: Rafal Ozieblo <rafalo@cadence.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1496413661-21452-1-git-send-email-rafalo@cadence.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 02, 2017 at 03:27:41PM +0100, Rafal Ozieblo wrote:
>  drivers/net/ethernet/cadence/macb.c      | 3568 ------------------------------
>  drivers/net/ethernet/cadence/macb_main.c | 3568 ++++++++++++++++++++++++++++++

You deleted macb.c, and so ...

> diff --git a/drivers/net/ethernet/cadence/Makefile b/drivers/net/ethernet/cadence/Makefile
> index 4ba7559..31ea6e3 100644
> --- a/drivers/net/ethernet/cadence/Makefile
> +++ b/drivers/net/ethernet/cadence/Makefile
> @@ -1,6 +1,7 @@
>  #
>  # Makefile for the Atmel network device drivers.
>  #
> +macb-y	:= macb_main.o
>  
>  obj-$(CONFIG_MACB) += macb.o

how does this rule make sense any more?

Thanks,
Richard
