From: Artem Bityutskiy <dedekind1@gmail.com>
Subject: Re: [PATCH 00/33] devm improvement series, part 1, take 2
Date: Thu, 16 May 2013 16:11:02 +0300
Message-ID: <1368709862.15764.224.camel@sauron.fi.intel.com>
References: <1368702961-4325-1-git-send-email-wsa@the-dreams.de>
 <1368705452.15764.217.camel@sauron.fi.intel.com>
 <CAKohpokUy7QfvKkzGH025Zs5VkUhr8zRLeo3caG3LAnLfptzww@mail.gmail.com>
Reply-To: dedekind1@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, alsa-devel@alsa-project.org,
 Alessandro Zummo <a.zummo@towertech.it>, Wolfram Sang <wsa@the-dreams.de>,
 Alexander Shishkin <alexander.shishkin@linux.intel.com>,
 Linus Walleij <linus.walleij@linaro.org>,
 Thierry Reding <thierry.reding@avionic-design.de>, linux-fbdev@vger.kernel.org,
 dri-devel@lists.freedesktop.org, Jaroslav Kysela <perex@perex.cz>,
 linux-ide@vger.kernel.org, linux-mtd@lists.infradead.org,
 linux-i2c@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>,
 ac100@lists.launchpad.net, devel@driverdev.osuosl.org,
 Kukjin Kim <kgene.kim@samsung.com>, Russell King <linux@arm.linux.org.uk>,
 Herbert Xu <herbert@gondor.apana.org.au>, Samuel Ortiz <sameo@linux.intel.com>,
 Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
 Vinod Koul <vinod.koul@intel.com>, linux-pm@vger.kernel.org,
 cpufreq@vger.kernel.org, Eduardo Valentin <eduardo.valentin@
To: Viresh Kumar <viresh.kumar@linaro.org>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <CAKohpokUy7QfvKkzGH025Zs5VkUhr8zRLeo3caG3LAnLfptzww@mail.gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel/>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: "devel" <devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Thu, 2013-05-16 at 18:25 +0530, Viresh Kumar wrote:
> On 16 May 2013 17:27, Artem Bityutskiy <dedekind1@gmail.com> wrote:
> > On Thu, 2013-05-16 at 13:15 +0200, Wolfram Sang wrote:
> >> Despite various architectures and platform dependencies, I managed to
> >> compile
> >> test 45 out of 57 modified files locally using heuristics and
> >> defconfigs.
> >> If somebody knows how to create a minimal .config with a certain
> >> kconfig symbol
> >> (and its dependencies) set, I'd love to hear about it.
> >
> > If you find this out, please, share!
> 
> Are you guys looking for "make savedefconfig" ??

No. It is more like:

I have changed this strange driver.

I want to compile-test my changes.

I need a defconfig which would have this driver enabled. I also want to
know <arch> for my "make ARCH=<arch>" command.

-- 
Best Regards,
Artem Bityutskiy
