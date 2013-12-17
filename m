From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hamradio/yam: fix info leak in ioctl
Date: Mon, 16 Dec 2013 20:11:27 -0500 (EST)
Message-ID: <20131216.201127.533912619440960142.davem@davemloft.net>
References: <1386920767-27962-1-git-send-email-speiro@ai2.upv.es>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, security@kernel.org,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org, jpr@f6fbb.org,
	stable@vger.kernel.org
To: speiro@ai2.upv.es
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1386920767-27962-1-git-send-email-speiro@ai2.upv.es>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Salva Peir=F3 <speiro@ai2.upv.es>
Date: Fri, 13 Dec 2013 08:46:07 +0100

> The yam_ioctl() code fails to initialise the cmd field
> of the struct yamdrv_ioctl_cfg. Add an explicit memset(0)
> before filling the structure to avoid the 4-byte info leak.
>=20
> Signed-off-by: Salva Peir=F3 <speiro@ai2.upv.es>

Put this into the SIOCYAMGCFG case statement, which is where the
problem actually exists.
--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
