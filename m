From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: phy: micrel: support !CONFIG_HAVE_CLK
Date: Mon, 27 Apr 2015 14:59:39 -0300
Message-ID: <CAOMZO5Dg9FkGkSS7mygv3OdfdF4jOK_nbTvx8eUTGD+EMmRs0g@mail.gmail.com>
References: <1430132450-4496-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>, johan@kernel.org,
	Niklas Cassel <niklass@axis.com>
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430132450-4496-1-git-send-email-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 27, 2015 at 8:00 AM, Niklas Cassel <niklas.cassel@axis.com> wrote:

> Since NULL is a valid clock, we shouldn't use
> IS_ERR_OR_NULL.

Yes, but this code is not using IS_ERR_OR_NULL.

It seems that you are not describing the problem you are trying to solve.

What is the exact issue you are seeing?

>         clk = devm_clk_get(&phydev->dev, "rmii-ref");

You need to provide the 'rmii-ref' in your board file or dts.

Are you doing this?
