From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 3/9] ARM: sun8i: dt: Add DT bindings documentation for
 Allwinner sun8i-emac
Date: Tue, 13 Sep 2016 16:12:02 +0200
Message-ID: <20160913141202.GO11400@lunn.ch>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
 <1473425117-18645-4-git-send-email-clabbe.montjoie@gmail.com>
 <20160909141710.GF30871@lunn.ch>
 <20160913133417.GC31990@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        devicetree@vger.kernel.org
To: LABBE Corentin <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160913133417.GC31990@Red>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 13, 2016 at 03:34:17PM +0200, LABBE Corentin wrote:
> On Fri, Sep 09, 2016 at 04:17:10PM +0200, Andrew Lunn wrote:
> > > +Optional properties:
> > > +- allwinner,tx-delay: TX clock delay chain value. Range value is 0-0x07. Default is 0)
> > > +- allwinner,rx-delay: RX clock delay chain value. Range value is 0-0x1F. Default is 0)
> > 
> > What are the units? pS? nS?
> > 
> >      Andrew
> 
> No units, only raw number.
> I will add a comment for this.

And it is likely it will get NACKed by the device tree
maintainers. You should use real unit here.

       Andrew
