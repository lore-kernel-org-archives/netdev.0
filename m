From: Clemens Gruber <clemens.gruber@pqgruber.com>
Subject: Re: [PATCH v2] phy: marvell: Fix and unify reg-init behavior
Date: Mon, 15 Feb 2016 23:34:24 +0100
Message-ID: <20160215223423.GA836@archie.tuxnet.lan>
References: <1455566460-31291-1-git-send-email-clemens.gruber@pqgruber.com>
 <CAOMZO5AO4KY+PcQ7ka5Ot-TL222frLO50On+tFXFWGkKhQ25PA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOMZO5AO4KY+PcQ7ka5Ot-TL222frLO50On+tFXFWGkKhQ25PA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fabio,

On Mon, Feb 15, 2016 at 06:54:29PM -0200, Fabio Estevam wrote:
> On Mon, Feb 15, 2016 at 6:01 PM, Clemens Gruber
> <clemens.gruber@pqgruber.com> wrote:
> 
> > +static int marvell_config_init(struct phy_device *phydev)
> > +{
> > +       int err;
> > +
> > +       /* Set registers from marvell,reg-init DT property */
> > +       err = marvell_of_reg_init(phydev);
> > +       if (err < 0)
> > +               return err;
> > +
> > +       return 0;
> >  }
> 
> Couldn't this be replaced by
> 
> return marvell_of_reg_init(phydev); ?

I wanted to add some missing errata fixes from the Marvell Release Notes
into that function (in the near future).
But you are right, I should probably not change things preemptively.

I'll send a v3 with that part replaced!

Thanks,
Clemens
