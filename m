From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH] e100: Don't enable WoL by default on Toshiba devices
Date: Thu, 15 Jan 2015 14:40:32 +0100
Message-ID: <201501151440.32159.linux@rainbow-software.org>
References: <1415832445-9524-1-git-send-email-linux@rainbow-software.org> <20141112.181813.1072534293888457853.davem@davemloft.net> <1415849927.2454.14.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415849927.2454.14.camel@jtkirshe-mobl>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 13 November 2014, Jeff Kirsher wrote:
> On Wed, 2014-11-12 at 18:18 -0500, David Miller wrote:
> > From: Ondrej Zary <linux@rainbow-software.org>
> > Date: Wed, 12 Nov 2014 23:47:25 +0100
> >
> > > Enabling WoL on some Toshiba laptops (such as Portege R100) causes
> > > battery drain after shutdown (WoL is active even on battery). These
> > > laptops have the WoL bit set in EEPROM ID, causing e100 driver to
> > > enable WoL by default.
> > >
> > > Check subsystem vendor ID and if it's Toshiba, don't enable WoL by
> > > default from EEPROM settings.
> > >
> > > Fixes https://bugs.launchpad.net/ubuntu/+source/linux/+bug/110784
> > >
> > > Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> >
> > Jeff, are you gonna pick this up?
>
> Yes, sorry I did not catch it earlier.

What happened to this patch? I don't see it in net.git or net-next.git 
(checked both davem's and jkirsher's)

-- 
Ondrej Zary
