From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 27/28] dsa: slave: Don't reference NULL pointer during
 phy_disconnect
Date: Wed, 23 Dec 2015 12:45:08 -0800
Message-ID: <567B07D4.60202@gmail.com>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <1450875402-20740-28-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:33154 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932509AbbLWUpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 15:45:10 -0500
Received: by mail-ob0-f171.google.com with SMTP id bx1so55481298obb.0
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 12:45:09 -0800 (PST)
In-Reply-To: <1450875402-20740-28-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/12/2015 04:56, Andrew Lunn a =C3=A9crit :
> When the phy is disconnected, the parent pointer to the netdev it was
> attached to is set to NULL. The code then tries to suspend the phy,
> but dsa_slave_fixed_link_update needs the parent pointer to determine
> which switch the phy is connected to. So it dereferenced a NULL
> pointer. Check for this condition.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
