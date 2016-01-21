From: Teresa Remmet <t.remmet@phytec.de>
Subject: Re: [PATCH v3] net: phy: smsc: Fix disabling energy detect mode
Date: Thu, 21 Jan 2016 09:43:34 +0100
Message-ID: <1453365814.3705.0.camel@lws-tremmet.phytec.de>
References: <1453293635-6121-1-git-send-email-t.remmet@phytec.de>
	 <20160120142155.GB28750@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160120142155.GB28750@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Andrew,

Am Mittwoch, den 20.01.2016, 15:21 +0100 schrieb Andrew Lunn:
> On Wed, Jan 20, 2016 at 01:40:35PM +0100, Teresa Remmet wrote:
> > When the lan87xx_read_status function is getting called the
> > energy detect mode is enabled again even if it has been
> > disabled by device tree.
> > 
> > Added private struct to check the energy detect status.
> > 
> > Signed-off-by: Teresa Remmet <t.remmet@phytec.de>
> 
> Hi Teresa
> 
> Looks a lot better now.
> 
> Reviewd-by: Andrew Lunn <andrew@lunn.ch>

thank you for taking the time to review the patch.

Regards,
Teresa

> 
> Thanks
> 	Andrew
