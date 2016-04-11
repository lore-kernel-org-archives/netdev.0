From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Subject: Re: AP firmware for TI wl1251 wifi chip (wl1251-fw-ap.bin)
Date: Mon, 11 Apr 2016 13:41:18 +0200
Message-ID: <20160411114118.GT8413@pali>
References: <201603200040.26045@pali>
 <20160404123944.GA8413@pali>
 <AE1C82FB3D0EC64DB1F752C81CBD1101390F6305@DFRE01.ent.ti.com>
 <201604061412.43684@pali>
 <AE1C82FB3D0EC64DB1F752C81CBD1101390F685E@DFRE01.ent.ti.com>
 <20160410115141.GD30188@xo-6d-61-c0.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Machani, Yaniv" <yanivma@ti.com>, "Chalmers, Kevin" <kev@ti.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"Davis, Andrew" <afd@ti.com>, "Mishol, Guy" <guym@ti.com>,
	Arik Nemtsov <arik@wizery.com>, Gery Kahn <geryk@ti.com>,
	Felipe Balbi <balbi@kernel.org>,
	David Woodhouse <dwmw2@infradead.org>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Gnedt <david.gnedt@davizone.at>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Sebastian Reichel <sre@kernel.org>,
	Tony Lindgren <tony@atomide.com>,
	"Menon, Nishanth" <nm@ti.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Pavel Machek <pavel@denx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160410115141.GD30188@xo-6d-61-c0.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 10 April 2016 13:51:41 Pavel Machek wrote:
> Is it "hardware can't do AP", "firmware can't do AP" or "current driv=
ers=20
> do not support AP"?

We know that current linux TI wl1251.ko driver does not support AP. And
I'm still do not know if "hardware can do AP" or not. Also I'm not sure=
=2E..
maybe current firmware can be "forced" for implementing AP mode.

David Gnedt implemented packet injection for wl1251.ko via JOIN firmwar=
e
command. And he wrote me that aircrack utils contains one application
which implementing full AP station in userspace just via packet
injection radiotap (which is supported by wl1251).

So maybe using other firmware (filter) commands together with current
packet injection implementation could be possible to create AP mode
(usable for standard hostapd daemon)? Just thinking...

Anyway, other TI wilink devices have different firmware for AP mode...

--=20
Pali Roh=C3=A1r
pali.rohar@gmail.com
