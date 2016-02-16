From: Simon Horman <horms@verge.net.au>
Subject: Re: ravb: Possible Regression In "net: phy: Avoid polling PHY with
 PHY_IGNORE_INTERRUPTS"
Date: Tue, 16 Feb 2016 14:12:25 +0900
Message-ID: <20160216051225.GA20714@verge.net.au>
References: <20160216032642.GE23315@verge.net.au>
 <09A8FCFB-F65F-4A0F-9464-B1026D553F6F@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Magnus Damm <magnus.damm@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <09A8FCFB-F65F-4A0F-9464-B1026D553F6F@gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On Mon, Feb 15, 2016 at 09:08:46PM -0800, Florian Fainelli wrote:
> On February 15, 2016 7:26:46 PM PST, Simon Horman <horms@verge.net.au> wrote:
> >Hi Florian,
> >
> >I have observed what appears to be a regression in the ravb ethernet
> >driver
> >caused by d5c3d84657db ("net: phy: Avoid polling PHY with
> >PHY_IGNORE_INTERRUPTS").
> >
> >When booting net-next configured with the ARM64 defconfig on the
> >Renesas
> >r8a7795/salvator-x I see the following and the ravb is unable to access
> >the
> >network. With the above mentioned patch reverted I am able to boot to
> >user-space using nfsroot.
> 
> Thanks for the report, I will take a closer look tomorrow, can you test patches easily on top of 4.5-rc on this platform?

Thanks.

Yes, I can easily test patches. The platform is supported in mainline as of
v4.5-rc (this problem aside) and I have access to a board.
