From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH 1/3] net: thunderx: Cleanup PHY probing code.
Date: Fri, 11 Mar 2016 13:57:56 -0800
Message-ID: <56E33F64.2000208@caviumnetworks.com>
References: <1457714822-5754-1-git-send-email-ddaney.cavm@gmail.com> <1457714822-5754-2-git-send-email-ddaney.cavm@gmail.com> <20160311173125.GI3153@lunn.ch> <56E30332.7060003@caviumnetworks.com> <20160311180030.GB19277@lunn.ch> <56E30DDF.5040506@caviumnetworks.com> <20160311190627.GC19277@lunn.ch> <56E31E7A.6080905@gmail.com> <56E330E4.9090800@gmail.com> <20160311213516.GE19277@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Daney <ddaney.cavm@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Robert Richter <rric@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	<netdev@vger.kernel.org>, David Daney <david.daney@cavium.com>,
	<linux-kernel@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
	Kumar Gala <galak@codeaurora.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160311213516.GE19277@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/11/2016 01:35 PM, Andrew Lunn wrote:
[...]
> How usable is the hardware without a PHY driver?

The hardware has always in the past, still does, and probably always 
will work fine without a PHY driver.  Link up/down are correctly handled.

> Is a better solution
> that your write a very minimal PHY driver?

No.  Nothing would be gained.

All we are trying to do, is allow for loading of 1G PHY drivers via the 
-EPROBE_DEFER mechanism while continuing to allow the 10G and 40G ports 
to function without a PHY driver.

Specifically, we are *not* attempting to solve the problem of 
re-architecting the kernel phy_device infrastructure so that it would be 
possible to write a Cortina PHYs driver.  Nor are we proposing that a 
Cortina PHY driver be written that would fit into the current 
infrastructure.

To this end, I still think the current patch takes the best approach.

Thanks,
David Daney
