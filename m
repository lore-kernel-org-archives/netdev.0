From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: [PATCH 00/33] devm improvement series, part 1, take 2
Date: Thu, 16 May 2013 18:13:58 +0200
Message-ID: <20130516161355.GA3032@katana>
References: <1368702961-4325-1-git-send-email-wsa@the-dreams.de>
 <1368705452.15764.217.camel@sauron.fi.intel.com>
 <CAKohpokUy7QfvKkzGH025Zs5VkUhr8zRLeo3caG3LAnLfptzww@mail.gmail.com>
 <1368709862.15764.224.camel@sauron.fi.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Viresh Kumar <viresh.kumar@linaro.org>,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        alsa-devel@alsa-project.org, linux-usb@vger.kernel.org,
        Alexander Shishkin <alexander.shishkin@linux.intel.com>,
        Linus Walleij <linus.walleij@linaro.org>,
        Matt Mackall <mpm@selenic.com>, linux-fbdev@vger.kernel.org,
        dri-devel@lists.freedesktop.org, Jaroslav Kysela <perex@perex.cz>,
        linux-ide@vger.kernel.org, Wim Van Sebroeck <wim@iguana.be>,
        netdev@vger.kernel.org, linux-mtd@lists.infradead.org,
        linux-i2c@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>,
        Wan ZongShun <mcuos.com@gmail.com>, ac100@lists.launchpad.net,
        devel@driverdev.osuosl.org, Kukjin Kim <kgene.kim@samsung.com>,
        Russell King <linux@arm.linux.org.uk>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Florian Tobias Sc
To: Artem Bityutskiy <dedekind1@gmail.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <1368709862.15764.224.camel@sauron.fi.intel.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org


> I need a defconfig which would have this driver enabled. 

My wish would be a minimal config. Right now, I try to build the driver
with the current config and when that fails I grep through the
(uncompressed) defconfigs for the symbol needed. Gives me 45/57 success
rate on this series. Not perfect, but the best I could come up with
without writing a .config-generator myself.
