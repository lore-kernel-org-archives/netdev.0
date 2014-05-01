From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH] arc_emac: write initial MAC address from devicetree to
 hw
Date: Thu, 1 May 2014 10:28:33 +0530
Message-ID: <5361D479.5010709@synopsys.com>
References: <1664530.jeK9vBIgft@typ>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Heiko Stuebner <heiko@sntech.de>
To: Max Schwarz <max.schwarz@online.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1664530.jeK9vBIgft@typ>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 18 April 2014 05:47 AM, Max Schwarz wrote:
> I recently noticed this problem on the Radxa Rock board. I'm not
> sure how this has ever worked on other platforms, though. I can
> only receive broadcast packets without configuring the address.
> 
> Running ifconfig eth0 hw ether XYZ or applying the patch fixes
> the problem for me.

Our rcS script would always do a ifconfig hw, hence we didn't run into this. We
have used this driver in one of our FPGA boards for several years.

-Vineet
