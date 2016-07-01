From: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Subject: RE: [RFC PATCH 2/2] net: macb: Add gmii2rgmii phy converter support
Date: Fri, 1 Jul 2016 13:07:29 +0000
Message-ID: <C246CAC1457055469EF09E3A7AC4E11A4A5BAB75@XAP-PVEXMBX01.xlnx.xilinx.com>
References: <1467354012-7364-1-git-send-email-appanad@xilinx.com>
 <1467354012-7364-3-git-send-email-appanad@xilinx.com>
 <57761F96.4060609@atmel.com>
 <C246CAC1457055469EF09E3A7AC4E11A4A5BA97B@XAP-PVEXMBX01.xlnx.xilinx.com>
 <57766A2D.5060507@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Michal Simek <michals@xilinx.com>,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	Harini Katakam <harinik@xilinx.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57766A2D.5060507@atmel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> >>> +static inline void macb_hw_fix_mac_speed(struct macb *bp,
> >>> +					 struct phy_device *phydev)
> >>> +{
> >>> +	if (likely(bp->converter_phy.fix_mac_speed))
> >>
> >> What is the purpose of this branch bias? The code isn't in some hot
> >> path, so I suspect that its not needed.
> >
> > If we won't put this check driver will crash with NULL pointer
> > dereference for the below cases
> 
> I know that...
> 
> > ---> Converter driver is disabled
> > ---> Converter driver is enabled but the converter probe is not called from the
> macb driver.
> 
> I didn't make myself clear: It's not the branch itself that I'm talking about it's the
> branch profiling directive "likely()" that seems not necessary.

Ok will remove in the next version...

Regards,
Kedar.
