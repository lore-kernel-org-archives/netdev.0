From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/6] mvneta: SGMII-based in-band link state signaling
Date: Fri, 27 Mar 2015 14:59:04 +0100
Message-ID: <20150327135904.GB11975@lunn.ch>
References: <55155AFC.4050800@list.ru>
 <20150327133907.GA11975@lunn.ch>
 <551560B9.1030505@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Stas Sergeev <stsp@list.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <551560B9.1030505@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> But there is no MDIO, because SGMII AFAIK doesn't need MDIO.
> SGMII has in-band status, but for some reason it seems currently
> linux is not ready for such setup - this is what my patch addresses.

Hacking the fixed-link driver feels wrong to me. You probably want to
implement an SGMII-link driver. With some refactoring you can probably
re-use some of the fixed-link driver code, but it should be a separate
driver, with its own DT binding.

But i'm no export here. So lets see what others say.

    Andrew
