From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 28/28] dsa: Destroy fixed link phys after the phy has
 been disconnected
Date: Wed, 23 Dec 2015 12:45:43 -0800
Message-ID: <567B07F7.9080701@gmail.com>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <1450875402-20740-29-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:36020 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965408AbbLWUpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 15:45:45 -0500
Received: by mail-oi0-f50.google.com with SMTP id o62so124401150oif.3
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 12:45:45 -0800 (PST)
In-Reply-To: <1450875402-20740-29-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/12/2015 04:56, Andrew Lunn a =C3=A9crit :
> The phy is disconnected from the slave in dsa_slave_destroy(). Don't
> destroy fixed link phys until after this, since there can be fixed
> linked phys connected to ports.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
