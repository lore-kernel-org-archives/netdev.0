From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH] net: mvneta: properly disable HW PHY polling and
 ensure adjust_link() works
Date: Thu, 5 Sep 2013 07:38:44 -0400
Message-ID: <20130905113844.GR19598@titan.lakedaemon.net>
References: <1378304478-21237-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <20130904163245.GI20552@1wt.eu>
 <CACzLR4uDQK2bkcEJQXLe805EfSA8=eF+YH-FTYovHA0q+8Y9NA@mail.gmail.com>
 <20130905051223.GB26000@1wt.eu>
 <20130905092808.617da416@skate>
 <20130905074426.GD26000@1wt.eu>
 <20130905102659.25a0f064@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, Lior Amsalem <alior@marvell.com>,
	Jochen De Smet <jochen.armkernel@leahnim.org>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Ryan Press <ryan@presslab.us>, netdev@vger.kernel.org,
	vdonnefort@lacie.com, Ethan Tuttle <ethan@ethantuttle.com>,
	stable@vger.kernel.org,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	=?iso-8859-1?Q?Ch=E9ny?= Yves-Gael <yves@cheny.fr>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Peter Sanford <psanford@nearbuy.io>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130905102659.25a0f064@skate>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 05, 2013 at 10:26:59AM +0200, Thomas Petazzoni wrote:
> On Thu, 5 Sep 2013 09:44:26 +0200, Willy Tarreau wrote:
> > One simpler solution for them could be to slightly modify the boot loader
> > so that it sets the MAC address on the two ethernet controllers prior to
> > boot. Then your code which checks if a MAC is already set will simply
> > work.
> 
> This works when the network driver is compiled 'statically' inside the
> kernel. When compiled as a module, then the gatable clock of the
> network interface will be gated at the end of the kernel boot, before
> the mvneta module is probe. And gating the network interface clocks
> means that it will loose its state, including its MAC address. So it's
> not an entirely perfect solution either, but I admit that on such
> platforms, the network driver is most likely compiled statically, so it
> would probably suit the needs of most people.

Up until sleep and standby modes are supported.  Proper power savings
would include gating the clock...

thx,

Jason.
