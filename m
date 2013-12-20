From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] can: ti_hecc: Replace platform dependency with ARM
 dependency
Date: Sat, 21 Dec 2013 00:17:27 +0300
Message-ID: <52B4B3E7.8050601@cogentembedded.com>
References: <1387570460-18409-1-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	netdev@vger.kernel.org, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1387570460-18409-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/20/2013 11:14 PM, Ezequiel Garcia wrote:

> OMAP's ti_hecc driver is used to support the CAN controller on many omap2plus
> SoCs (OMAP2430, OMAP3, OMAP4, OMAP5 and AM335x), so it's wrong to make this
> depend on OMAP3 only. Take an extra step, to get wider build coverage, and make
> the driver depend on ARM.

    To have a real wide coverage, it's probably worth adding '|| COMIPLE_TEXT' 
to 'depends on ARCH_OMAP2PLUS'?

> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>

WBR, Sergei


