From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/5] net: mdio-mux: Misc fix
Date: Wed, 30 Aug 2017 21:01:19 +0200
Message-ID: <20170830190119.GK22289@lunn.ch>
References: <20170830174651.30325-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170830174651.30325-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2017 at 07:46:46PM +0200, Corentin Labbe wrote:
> Hello
> 
> This patch series fix minor problems found when working on the
> dwmac-sun8i syscon mdio-mux.

Hi Corentin

In general, a nice patchset.

Looking at the code, there are a few calls to devm_kfree() which look
redundant. This one should probably stay:

	   	if (r) {
			mdiobus_free(cb->mii_bus);
			devm_kfree(dev, cb);
		} else {

but i think the others can go.

Just a suggestion, not a problem if you don't feel like doing this...

   Andrew
