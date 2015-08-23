From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/9] dsa: mv88e6xxx: Allow speed/duplex of port
 to be configured
Date: Sun, 23 Aug 2015 11:52:02 -0700
Message-ID: <55DA1652.1090103@gmail.com>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch> <1440323220-20438-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:36725 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752399AbbHWSwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 14:52:04 -0400
Received: by obkg7 with SMTP id g7so96241304obk.3
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 11:52:04 -0700 (PDT)
In-Reply-To: <1440323220-20438-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/23/15 02:46, Andrew Lunn a =C3=A9crit :
> The current code sets user ports to perform auto negotiation using th=
e
> phy. CPU and DSA ports are configured to full duplex and maximum spee=
d
> the switch supports.
>=20
> There are however use cases where the CPU has a slower port, and when
> user ports have SFP modules with fixed speed. In these cases, port
> settings to be read from a fixed_phy devices. The switch driver then
> needs to implement the adjust_link op, so the port settings can be
> set.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
