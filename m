From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: mvneta: properly disable HW PHY polling and ensure
 adjust_link() works
Date: Thu, 5 Sep 2013 11:24:32 +0200
Message-ID: <20130905112432.5854119e@skate>
References: <1378304478-21237-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<20130904163245.GI20552@1wt.eu>
	<CACzLR4uDQK2bkcEJQXLe805EfSA8=eF+YH-FTYovHA0q+8Y9NA@mail.gmail.com>
	<20130905051223.GB26000@1wt.eu>
	<20130905092808.617da416@skate>
	<20130905074426.GD26000@1wt.eu>
	<20130905102659.25a0f064@skate>
	<20130905091147.GA28658@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ethan Tuttle <ethan@ethantuttle.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Jochen De Smet <jochen.armkernel@leahnim.org>,
	Peter Sanford <psanford@nearbuy.io>,
	=?UTF-8?B?Q2jDqW55?= Yves-Gael <yves@cheny.fr>,
	Ryan Press <ryan@presslab.us>,
	Simon Guinot <simon.guinot@sequanux.org>, vdonnefort@lacie.com,
	stable@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>
To: Willy Tarreau <w@1wt.eu>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130905091147.GA28658@1wt.eu>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Willy Tarreau,

On Thu, 5 Sep 2013 11:11:47 +0200, Willy Tarreau wrote:

> 
> > Note that this can be done without doing any change in the bootloader.
> > For example, on a Mirabox, you can do:
> > 
> >    mw.l 0xD0072414 0x5C93; mw.l 0xD0072418 0xF0AD4E01; mw.l 0xD0076414 0x5C94; mw.l 0xD0076418 0xF0AD4E01; bootm
> > 
> > to boot your kernel. This will program the MAC addresses for both
> > network interfaces in the network controllers, so that when booting
> > Linux, you get:
> > 
> > [   42.122881] mvneta d0070000.ethernet eth0: Using hardware mac address f0:ad:4e:01:5c:93
> > [   42.385398] mvneta d0074000.ethernet eth1: Using hardware mac address f0:ad:4e:01:5c:94
> > 
> > You add that to your default U-Boot boot script, and that's it, you
> > have stable MAC addresses.
> 
> Hmmm that's quite interesting. Unfortunately I don't see an easy way to
> make this directly rely on the ethaddr/eth1addr so that end users can
> simply cut-n-paste a few lines into the u-boot config. But anyway that
> can be useful.

I thought about this as well, but I don't think that's possible, the
U-Boot scripting/parsing capabilities seems to be too limited to
achieve that, unfortunately.

Best regards,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
