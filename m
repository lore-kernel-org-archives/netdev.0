From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/9] phy: fixed_phy: Set supported speed in phydev
Date: Sun, 23 Aug 2015 11:54:16 -0700
Message-ID: <55DA16D8.9040304@gmail.com>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch> <1440323220-20438-4-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:32952 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635AbbHWSyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 14:54:18 -0400
Received: by obbhe7 with SMTP id he7so96424045obb.0
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 11:54:17 -0700 (PDT)
In-Reply-To: <1440323220-20438-4-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/23/15 02:46, Andrew Lunn a =C3=A9crit :
> Set the supported field of the phydev to indicate the speed features
> of the phy. If the phy is never attached to a netdev, but used in an
> adjust_link() function, the speed will be incorrectly evaluated to
> 10/half rather than the correct speed/duplex.

As mentioned in patch 4, the behavior is not really specified before yo=
u
attach to the PHY device, and therefore configured by the PHY library,
still:

>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
