From: Chen-Yu Tsai <wens@csie.org>
Subject: Re: [PATCH 2/4] net: rfkill: gpio: remove gpio names
Date: Fri, 21 Feb 2014 09:55:28 +0800
Message-ID: <CAGb2v66-tDZhrm9dnXe+PdQTaLZbw20sw3uYzLor2eXpVWmPMA@mail.gmail.com>
References: <1392900697-27577-1-git-send-email-heikki.krogerus@linux.intel.com>
 <1392900697-27577-3-git-send-email-heikki.krogerus@linux.intel.com> <53062F97.3050407@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Rhyland Klein <rklein@nvidia.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <gnurou@gmail.com>
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53062F97.3050407@wwwdotorg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, Feb 21, 2014 at 12:38 AM, Stephen Warren <swarren@wwwdotorg.org> wrote:
> On 02/20/2014 05:51 AM, Heikki Krogerus wrote:
>> There is no use for them in this driver. This will fix a
>> static checker warning..
>
> Didn't you remove the use:
>
> -       gpio = devm_gpiod_get_index(&pdev->dev, rfkill->reset_name, 0);
> +       gpio = devm_gpiod_get_index(&pdev->dev, NULL, 0);
>
> doesn't that parameter get put into the sysfs GPIO debug file, so people
> can see which GPIOs are used for what?

That's correct. However using con_id to pass this results in different
behavior across DT and ACPI. A better way is to export the labeling
function so consumers can set meaningful labels themselves.


Cheers
ChenYu
