From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: rfkill-regulator: Add devicetree support.
Date: Mon, 10 Feb 2014 09:27:42 +0100
Message-ID: <1392020862.4128.1.camel@jlt4.sipsolutions.net>
References: <1391802529-29861-1-git-send-email-marek@goldelico.com>
	 (sfid-20140207_204900_539631_47DCB6B7)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rob@landley.net, linville@tuxdriver.com, davem@davemloft.net,
	grant.likely@linaro.org, neilb@suse.de, hns@goldelico.com,
	devicetree@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Marek Belisko <marek@goldelico.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1391802529-29861-1-git-send-email-marek@goldelico.com> (sfid-20140207_204900_539631_47DCB6B7)
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-02-07 at 20:48 +0100, Marek Belisko wrote:

> +#define RFKILL_TYPE_ALL		(0)
> +#define RFKILL_TYPE_WLAN	(1)
> +#define RFKILL_TYPE_BLUETOOTH	(2)
> +#define RFKILL_TYPE_UWB		(3)
> +#define RFKILL_TYPE_WIMAX	(4)
> +#define RFKILL_TYPE_WWAN	(5)
> +#define RFKILL_TYPE_GPS		(6)
> +#define RFKILL_TYPE_FM		(7)
> +#define RFKILL_TYPE_NFC		(8)

This seems like a bad idea since there's an enum elsewhere in userspace
API already.

johannes

