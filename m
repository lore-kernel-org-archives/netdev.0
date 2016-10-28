From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [v15, 3/7] powerpc/fsl: move mpc85xx.h to include/linux/fsl
Date: Fri, 28 Oct 2016 12:52:44 +0200
Message-ID: <2723366.1bJeJ7SKI6@wuerfel>
References: <1477637418-38938-1-git-send-email-yangbo.lu@nxp.com> <1477637418-38938-4-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Yangbo Lu <yangbo.lu@nxp.com>, linux-mmc@vger.kernel.org,
        ulf.hansson@linaro.org, Scott Wood <oss@buserror.net>,
        Mark Rutland <mark.rutland@arm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Xiaobo Xie <xiaobo.xie@nxp.com>,
        Minghuan Lian <minghuan.lian@nxp.com>,
        linux-i2c@vger.kernel.org, linux-clk@vger.kernel.org,
        Qiang Zhao <qiang.zhao@nxp.com>,
        Russell King <linux@arm.linux.org.uk>,
        Bhupesh Sharma <bhupesh.sharma@freescale.com>,
        Joerg Roedel <joro@8bytes.org>,
        Claudiu Manoil <claudiu.manoil@freescale.com>,
        devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        Santosh Shilimkar <ssantosh@kernel.org>,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Leo Li <leoyang.li@nxp.com>,
        iommu@lists.linux-fou
To: linuxppc-dev@lists.ozlabs.org
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1477637418-38938-4-git-send-email-yangbo.lu@nxp.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, October 28, 2016 2:50:14 PM CEST Yangbo Lu wrote:
> Move mpc85xx.h to include/linux/fsl and rename it to svr.h as a common
> header file.  This SVR numberspace is used on some ARM chips as well as
> PPC, and even to check for a PPC SVR multi-arch drivers would otherwise
> need to ifdef the header inclusion and all references to the SVR symbols.
> 
> 

I don't see any of the contents of this header referenced by the soc driver
any more. I think you can just drop this patch.

	Arnd

