From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3] net: ethernet: faraday: To support device tree usage.
Date: Tue, 03 Jan 2017 14:24:35 +0100
Message-ID: <2299808.LHnPolcyRJ@wuerfel>
References: <1483083470-15779-1-git-send-email-green.hu@gmail.com> <6434425.l4ZxB6kK6L@wuerfel> <CAEbi=3cJtHr-G+CHzAMgsfoscj6Eb=YUJeXB7=AmmT5DrHOqXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, devicetree@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
        Jiri Pirko <jiri@resnulli.us>
To: Greentime Hu <green.hu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEbi=3cJtHr-G+CHzAMgsfoscj6Eb=YUJeXB7=AmmT5DrHOqXg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, January 3, 2017 2:05:47 PM CET Greentime Hu wrote:
> ​I am not sure if atmac and moxa-art are exactly hardware compatible though
> they are based on faraday ftmac.
> It may be better if we use 2 different device tree binding documents to
> describe for these 2 different drivers to use.

They are probably slightly different, but close enough to have the same
binding document, as there is no technical reason to have two separate
drivers for them. The binding should be about the hardware type, not the
way that Linux currently implements the drivers.

	Arnd
