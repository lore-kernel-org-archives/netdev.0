From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/5] dsa: Rename mv88e6123_61_65 to mv88e6123 to be consistent
Date: Sun, 13 Mar 2016 03:10:13 -0400
Message-ID: <87io0qua3u.fsf@ketchup.mtl.sfl>
References: <1457737300-23660-1-git-send-email-andrew@lunn.ch> <1457737300-23660-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34800 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567AbcCMHKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 03:10:18 -0400
In-Reply-To: <1457737300-23660-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> All the drivers support multiple chips, but mv88e6123_61_65 is the
> only one that reflects this in its naming. Change it to be consistent
> with the other drivers.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

When mv88e6xxx will become a driver by its own supporting different
devices, it'll be good to rename it to a reference driver as well, say
mv88e6352.

[...]

> diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
> new file mode 100644
> index 000000000000..69a6f79dcb10
> --- /dev/null
> +++ b/drivers/net/dsa/mv88e6123.c
> @@ -0,0 +1,124 @@

Note that to avoid the big diff above, you can use the -M option of
git-format-patch to detect file renames.

Thanks,
Vivien
