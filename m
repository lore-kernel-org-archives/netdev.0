From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH net-next 0/6] net: dsa: mv88e6060: cleanup and fix
 setup
Date: Mon, 2 Nov 2015 10:41:23 -0500
Message-ID: <20151102154121.GB3036@ketchup.mtl.sfl>
References: <5637417D.6060503@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:35746 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754101AbbKBPlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 10:41:25 -0500
Content-Disposition: inline
In-Reply-To: <5637417D.6060503@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neil,

On Nov. Monday 02 (45) 11:57 AM, Neil Armstrong wrote:
> This patchset introduces somes fixes and a registers addressing cleanup for
> the mv88e6060 DSA driver.
> 
> The first patch removes the poll_link as mv88e6xxx.
> The 3 following patchs fixes the setup in regards of the datasheet.
> The 2 last patches introduces a clean header and replaces all magic values.
> 
> Neil Armstrong (6):
>   net: dsa: mv88e6060: remove poll_link callback
>   net: dsa: mv88e6060: use the correct InitReady bit
>   net: dsa: mv88e6060: use the correct MaxFrameSize bit
>   net: dsa: mv88e6060: use the correct bit shift for mac0
>   net: dsa: mv88e6060: add register defines header file
>   net: dsa: mv88e6060: replace magic values with register defines

Nice cleanup. I'll just be a bit picky here, so you may not consider my
comment for this patchset, but maybe for the future ones. Unless I'm
mistaken, there is no reason to group all these patches together.

The first 4 patches are independent fixes, and thus could have been sent
separately to netdev -net.

Then the last 2 ones could have been squashed together, because I don't
see a real value to seperate them since you duplicate some defines, e.g.
REG_PORT. And this patch would be a candidate for netdev -net-next.

Thanks,
-v
