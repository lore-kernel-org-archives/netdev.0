From: Stephen Warren <swarren@wwwdotorg.org>
Subject: Re: [PATCH 2/4] net: rfkill: gpio: remove gpio names
Date: Thu, 20 Feb 2014 09:38:47 -0700
Message-ID: <53062F97.3050407@wwwdotorg.org>
References: <1392900697-27577-1-git-send-email-heikki.krogerus@linux.intel.com> <1392900697-27577-3-git-send-email-heikki.krogerus@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Chen-Yu Tsai <wens@csie.org>, Rhyland Klein <rklein@nvidia.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <gnurou@gmail.com>
To: Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392900697-27577-3-git-send-email-heikki.krogerus@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/20/2014 05:51 AM, Heikki Krogerus wrote:
> There is no use for them in this driver. This will fix a
> static checker warning..

Didn't you remove the use:

-	gpio = devm_gpiod_get_index(&pdev->dev, rfkill->reset_name, 0);
+	gpio = devm_gpiod_get_index(&pdev->dev, NULL, 0);

doesn't that parameter get put into the sysfs GPIO debug file, so people
can see which GPIOs are used for what?
