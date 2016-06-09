From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: stmmac: dwmac-rk: keep PHY up for WoL
Date: Thu, 9 Jun 2016 02:17:39 +0200
Message-ID: <20160609001739.GA2227@lunn.ch>
References: <1464974960-26672-1-git-send-email-vpalatin@chromium.org>
 <f543c3e1-fa55-a6fd-c916-cf043e562ec2@st.com>
 <CAP_ceTwLg-e_gUaYLrUiBy8Fu31n=UemzbA_sDP2_-5wiY2p5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Alexandre Torgue <alexandre.torgue@st.com>,
	Heiko =?iso-8859-1?Q?St=FCbner?= <heiko@sntech.de>
To: Vincent Palatin <vpalatin@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39375 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932421AbcFIARo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2016 20:17:44 -0400
Content-Disposition: inline
In-Reply-To: <CAP_ceTwLg-e_gUaYLrUiBy8Fu31n=UemzbA_sDP2_-5wiY2p5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 08, 2016 at 03:25:38PM -0700, Vincent Palatin wrote:
> On Tue, Jun 7, 2016 at 12:23 AM, Giuseppe CAVALLARO
> <peppe.cavallaro@st.com> wrote:
> > Hello
> >
> > On 6/3/2016 7:29 PM, Vincent Palatin wrote:
> >>
> >> Do not shutdown the PHY if Wake-on-Lan is enabled, else it cannot wake
> >> us up.
> >>
> >
> > I do not understand why you need that.
> > This is done inside the PHY layer and it is tested on our platforms
> > he idea is: If the parent wants to Wake the system then the PHY should
> > not power-down.
> 
> I'm not sure I understand :
> you mean that this path is not called if WoL is enabled ?
> [ currently stmmac_pltfr_suspend() is calling priv->plat->exit() which
> is the rk_gmac_exit() code I'm modifying ]
> or the RK driver code should not power down the phy in its exit() callback ?

Take a look at phy_suspend().

     Andrew
