From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH 0/5] net: mdio-mux: Misc fix
Date: Fri, 1 Sep 2017 10:30:15 +0200
Message-ID: <20170901083015.GA6203@Red>
References: <20170830174651.30325-1-clabbe.montjoie@gmail.com>
 <20170830190119.GK22289@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170830190119.GK22289@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2017 at 09:01:19PM +0200, Andrew Lunn wrote:
> On Wed, Aug 30, 2017 at 07:46:46PM +0200, Corentin Labbe wrote:
> > Hello
> > 
> > This patch series fix minor problems found when working on the
> > dwmac-sun8i syscon mdio-mux.
> 
> Hi Corentin
> 
> In geineral, a nice patchset.

Thanks, I will send a v2 with your suggestions.

> 
> Looking at the code, there are a few calls to devm_kfree() which look
> redundant. This one should probably stay:
> 
> 	   	if (r) {
> 			mdiobus_free(cb->mii_bus);
> 			devm_kfree(dev, cb);
> 		} else {
> 
> but i think the others can go.
> 
> Just a suggestion, not a problem if you don't feel like doing this...
> 

I will try but in another serie. For letting more time for test.

Regards
