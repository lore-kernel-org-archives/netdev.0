From: Stephen Warren <swarren@wwwdotorg.org>
Subject: Re: [PATCH 5/7] net: rfkill: gpio: add device tree support
Date: Tue, 15 Apr 2014 15:01:59 -0600
Message-ID: <534D9E47.30708@wwwdotorg.org>
References: <1397544101-18135-1-git-send-email-wens@csie.org> <1397544101-18135-6-git-send-email-wens@csie.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alexandre Courbot <gnurou@gmail.com>,
	Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Arnd Bergmann <arnd@arndb.de>, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, linux-sunxi@googlegroups.com,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-gpio@vger.kernel.org,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	linux-arm-kernel@lists.infradead.org
To: Chen-Yu Tsai <wens@csie.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1397544101-18135-6-git-send-email-wens@csie.org>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/15/2014 12:41 AM, Chen-Yu Tsai wrote:

> diff --git a/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt b/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt

> +Optional properties:
> +- clocks		: phandle to clock to enable/disable

Oh, and can't we use clock-names here too, with wording like:

- clocks: Must contain an entry for each entry in clock-names.
  See ../clocks/clock-bindings.txt for details.
- clock-names: May contain any of the following entries:
  - module

