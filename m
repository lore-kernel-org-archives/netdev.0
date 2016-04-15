From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Fri, 15 Apr 2016 10:35:29 -0700
Message-ID: <20160415173529.GY391@tuxbot>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <570EC541.6080603@gmail.com>
 <570FFB6B.5060305@codeaurora.org>
 <57100962.40404@gmail.com>
 <571012E6.6050303@codeaurora.org>
 <57102920.7000104@codeaurora.org>
 <20160415164433.GV391@tuxbot>
 <57111E33.606@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vikram Sethi <vikrams@codeaurora.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>, cov@codeaurora.org,
	gavidov@codeaurora.org, Rob Herring <robh+dt@kernel.org>,
	andrew@lunn.ch, Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57111E33.606@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri 15 Apr 10:00 PDT 2016, Timur Tabi wrote:

> Bjorn Andersson wrote:
> >For platform devices being populated via from DT you will pass:
> >of_platform_bus_create()
> >   of_platform_device_create_pdata()
> >     of_dma_configure()
> >
> >Which calls of_dma_get_range() to acquire this information from the
> >dma-ranges property and set up the dma ops and properties.
> 
> This seems excessive.  I have to create a platform bus just to configure the
> DMA mask?  Most drivers just call dma_set_mask and give it a number, and
> that's not device-tree specific.  I also need to come up with a way to get
> this to work on ACPI.
> 
> I just seems like a lot of work only because I need to determine at runtime
> what my DMA mask is.  I also don't see any drivers that call
> of_dma_configure().
> 

Your driver is a platform driver and it's being probed from DT. As such
all this is already taken care of for you, by the core.

The listing is for your reference to know why the dma-ranges property
would affect your device.

Regards,
Bjorn
