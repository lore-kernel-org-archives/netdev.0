From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v4] net: phy: micrel: Fix regression in kszphy_probe
Date: Mon, 11 May 2015 12:31:12 -0300
Message-ID: <CAOMZO5C1gjz=DHOY8TP8G1Ugni3r_Jfva+mN5d1RTcCmA=eSmw@mail.gmail.com>
References: <1431357666-6808-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>, johan@kernel.org,
	Niklas Cassel <niklass@axis.com>,
	stable <stable@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1431357666-6808-1-git-send-email-niklass@axis.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 11, 2015 at 12:21 PM, Niklas Cassel <niklas.cassel@axis.com> wrote:
> Don't do clock-mode-select if clk == NULL,
> since when building without CONFIG_HAVE_CLK,
> clk_get returns NULL and clk_get_rate returns 0.
>
> Doing clock-mode-select in this cause causes kszphy_probe to
> return -EINVAL and thus prevents the device from being probed.
>
> The original code (before regression) would return 0
> when building without CONFIG_HAVE_CLK.
>
> Cc: stable <stable@vger.kernel.org> # 3.18+
> 1fadee0c3645 ("net/phy: micrel: Add clock support for
> KSZ8021/KSZ8031")
> Signed-off-by: Niklas Cassel <niklass@axis.com>

Looks good now:

Reviewed-by: Fabio Estevam <fabio.estevam@freescale.com>
