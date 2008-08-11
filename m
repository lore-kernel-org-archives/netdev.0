From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: ath9k build failure
Date: Mon, 11 Aug 2008 09:46:57 -0700
Message-ID: <20080811164657.GE6128@tesla>
References: <20080811162040.ed7b8ab7.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Luis Rodriguez <Luis.Rodriguez@Atheros.com>,
	Sujith Manoharan <Sujith.Manoharan@Atheros.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080811162040.ed7b8ab7.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 10, 2008 at 11:20:40PM -0700, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next build (powerpc allyesconfig) failed like this:
> 
> drivers/net/wireless/ath9k/hw.c: In function 'ath9k_hw_spur_mitigate':
> drivers/net/wireless/ath9k/hw.c:4925: internal compiler error: in expand_expr_real_1, at expr.c:9199
> 
> This is a driver that is in Linus' tree and has no patches in the
> linux-next tree.
> 
> The original work around talked about applying the patch twice, so I
> applied the below patch.

Stephen,

this is also in wireless-testing. I also see this in linux-2.6
under b08cbcd4546445740c2a04291204b56f8baf7be2. Not sure how this didn't
get through linux-next.

  Luis
