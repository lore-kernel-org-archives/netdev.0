From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Wed, 19 Jan 2011 08:41:30 -0800
Message-ID: <1295455290.1952.22.camel@Joe-Laptop>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
	 <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
	 <1295284788.21277.65.camel@Joe-Laptop>
	 <AANLkTi=nJxwR89CF3i0+L6+yM4Bg_PN8PQByTAHP2nPM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ratbert@faraday-tech.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, dilinger@queued.net
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=nJxwR89CF3i0+L6+yM4Bg_PN8PQByTAHP2nPM@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-01-19 at 17:40 +0800, Po-Yu Chuang wrote:
> On Tue, Jan 18, 2011 at 1:19 AM, Joe Perches <joe@perches.com> wrote:
> > on split long line indentation style
> > and long function declarations.
[]
> > Most of drivers/net uses an alignment to open parenthesis
> > using maximal tabs and minimal necessary spaces instead of
> > an extra tabstop.
[]
> Well, TBH, I don't like this style because if I changed the
> function name, the indentation might need to be adjusted.

No worries.  That could happen using either style.

There's no required style so you can use what you are
most comfortable doing.  It's not a big deal at all.

> Even worse, I got an infeasible case :-(
> 
> static struct ftmac100_rxdes *ftmac100_rx_locate_first_segment(
> 							       struct ftmac100 *priv)
> 
> I know my function names are quite long, but I like them to be descriptive.
> Do you really insist on it?

Here's a common alternative style for this case:

static struct ftmac100_rxdes *
ftmac100_rx_locate_first_segment(struct ftmac100 *priv)
