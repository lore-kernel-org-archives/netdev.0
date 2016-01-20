From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3] net: phy: smsc: Fix disabling energy detect mode
Date: Wed, 20 Jan 2016 15:21:55 +0100
Message-ID: <20160120142155.GB28750@lunn.ch>
References: <1453293635-6121-1-git-send-email-t.remmet@phytec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Teresa Remmet <t.remmet@phytec.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1453293635-6121-1-git-send-email-t.remmet@phytec.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 20, 2016 at 01:40:35PM +0100, Teresa Remmet wrote:
> When the lan87xx_read_status function is getting called the
> energy detect mode is enabled again even if it has been
> disabled by device tree.
> 
> Added private struct to check the energy detect status.
> 
> Signed-off-by: Teresa Remmet <t.remmet@phytec.de>

Hi Teresa

Looks a lot better now.

Reviewd-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew
