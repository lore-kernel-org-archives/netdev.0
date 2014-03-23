From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH V11 2/7] net: sxgbe: add basic framework for Samsung 10Gb
 ethernet driver
Date: Sat, 22 Mar 2014 17:39:50 -0700
Message-ID: <008d01cf4630$6896edd0$39c4c970$@samsung.com>
References: <007f01cf4597$50abac40$f20304c0$@samsung.com>
 <CAOwfj2MvqxwGxSUiOxYv4mrrLpXY-Nchi5PSZVVwATVr7YRYMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org, 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>,
	'Jay Bhat' <j.bhat@samsung.com>
To: 'Vince Bridgers' <vbridgers2013@gmail.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-reply-to: <CAOwfj2MvqxwGxSUiOxYv4mrrLpXY-Nchi5PSZVVwATVr7YRYMg@mail.gmail.com>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vince Bridgers <vbridgers2013@gmail.com> :
> On Sat, Mar 22, 2014 at 1:23 AM, Byungho An <bh74.an@samsung.com> wrote:
> > From: Siva Reddy <siva.kallam@samsung.com>
> >
> > This patch adds support for Samsung 10Gb ethernet driver(sxgbe).

[snip]

> > +       /* Stop Advertising 1000BASE Capability if interface is not GMII
*/
> > +       if ((phy_iface == PHY_INTERFACE_MODE_MII) ||
> > +           (phy_iface == PHY_INTERFACE_MODE_RMII))
> > +               phydev->advertising &= ~(SUPPORTED_1000baseT_Half |
> > +                                        SUPPORTED_1000baseT_Full);
> 
> Your bindings document says sgmii and xgmii are possible. This code
> implies MII, RMII are possible (since you're checking for it). Is this
> needed?
As of now it is not needed, it is for future compatibility. anyway i'll remove
in this serise.

[sinp]

> > +               next_entry = (++priv->rxq[qnum]->cur_rx) % rxsize;
> > +               prefetch(priv->rxq[qnum]->dma_rx + next_entry);
> > +
> > +               /*TO DO read the status of the incoming frame */
> 
> Did you intend to leave a "TO DO" in a V11 submission?
it is not for this patch but for later patch.

> 
> 
> All the best,
> 
> Vince
> 
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
