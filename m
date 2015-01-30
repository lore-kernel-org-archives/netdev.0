From: Scott Wood <scottwood@freescale.com>
Subject: Re: [v4] QE: Move QE from arch/powerpc to drivers/soc
Date: Thu, 29 Jan 2015 23:22:08 -0600
Message-ID: <20150130052208.GA14431@home.buserror.net>
References: <1415763613-43674-1-git-send-email-B45475@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linuxppc-dev@lists.ozlabs.org>, <B07421@freescale.com>,
	<R63061@freescale.com>
To: Zhao Qiang <B45475@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1415763613-43674-1-git-send-email-B45475@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 12, 2014 at 11:40:13AM +0800, Zhao Qiang wrote:
> ls1 has qe and ls1 has arm cpu.
> move qe from arch/powerpc to drivers/soc/fsl
> to adapt to powerpc and arm
> 
> Signed-off-by: Zhao Qiang <B45475@freescale.com>
> ---
> Changes for v2:
> 	- move code to driver/soc
> Changes for v3:
> 	- change drivers/soc/qe to drivers/soc/fsl-qe
> Changes for v4:
> 	- move drivers/soc/fsl-qe to drivers/soc/fsl/qe
> 	- move head files for qe from include/linux/fsl to include/soc/fsl
> 	- move qe_ic.c to drivers/irqchip/

Need MAINTAINERS update for drivers/soc/fsl/qe, as previously discussed.

-Scott
