From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH 2/4] net: rfkill: gpio: remove gpio names
Date: Fri, 7 Mar 2014 10:58:51 +0800
Message-ID: <CACRpkdaU3OCa1qDojcBK4Ci+YfOC7YfqLWqqBiwzh9vfEasH+g@mail.gmail.com>
References: <1392900697-27577-1-git-send-email-heikki.krogerus@linux.intel.com>
	<1392900697-27577-3-git-send-email-heikki.krogerus@linux.intel.com>
	<53062F97.3050407@wwwdotorg.org>
	<CAGb2v66-tDZhrm9dnXe+PdQTaLZbw20sw3uYzLor2eXpVWmPMA@mail.gmail.com>
	<5306E599.7020605@wwwdotorg.org>
	<CACRpkdZBvKU31EDX=6=wVLXaQDAqD6VHtaE_mGnFLr1UYQAH9g@mail.gmail.com>
	<BD75D217E5BAC84080F8EFB2582976378B327178@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Warren <swarren@wwwdotorg.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	Grant Likely <grant.likely@linaro.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Chen-Yu Tsai <wens@csie.org>,
	Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Rhyland Klein <rklein@nvidia.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>,
	"Westerberg, Mika" <mika.westerberg@intel.com>,
	"mgross@linux.intel.com" <mgross@linux.intel.com>
To: "Gross, Mark" <mark.gross@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BD75D217E5BAC84080F8EFB2582976378B327178@ORSMSX109.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 28, 2014 at 1:38 AM, Gross, Mark <mark.gross@intel.com> wrote:

> So if you have the luxury of being able to influence (file bugs against or write)
> the platform enumeration ABI then with ACPI you can have a named gpio today.
> Note: there is an expectation that the _PRP feature to go into the next version
> of ACPI and that should enable a trivial 1-1 mapping (when _prp is used by the
> ACPI platform) between the different platform enumeration API's (DT and ACPI).

Oh I wasn't aware. This makes things better, and gives con_id a clear usecase
in the ACPI probe path as well.

[Stephen]
>> If there were ever an (upstream?) ACPI "binding"(?) for the Tegra SDHCI
>> controller, I would hope it would use the exact same names for the GPIO
>> signals.
>
> me to!

Amen to that.

Yours,
Linus Walleij
