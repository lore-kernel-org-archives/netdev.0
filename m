From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 13/17] net: dsa: mv88e6xxx: Rename _phy_ to _mdio_
Date: Fri, 03 Jun 2016 15:40:47 -0400
Message-ID: <8737ounjr4.fsf@ketchup.mtl.sfl>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch> <1464972256-10408-14-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:52470 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbcFCTkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 15:40:51 -0400
In-Reply-To: <1464972256-10408-14-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> The switch implements a generic MDIO bus, which could host more than
> PHYs. It is conventional to use _mdio_ or _mii_ in the function name,
> so rename them. Also postfix make the historically first read/write
> function with _direct, to help distinguish it from _indirect and _ppu.
>
> While touching these functions, remove some of the _ prefixes, which
> we are deprecating.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
