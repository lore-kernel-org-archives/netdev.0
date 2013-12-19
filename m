From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] hamradio/yam: fix info leak in ioctl
Date: Thu, 19 Dec 2013 15:09:58 -0500 (EST)
Message-ID: <20131219.150958.1721621193135421738.davem@davemloft.net>
References: <1386920767-27962-1-git-send-email-speiro@ai2.upv.es>
	<1387271191-10355-1-git-send-email-speiro@ai2.upv.es>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, security@kernel.org,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org, jpr@f6fbb.org,
	stable@vger.kernel.org
To: speiro@ai2.upv.es
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1387271191-10355-1-git-send-email-speiro@ai2.upv.es>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Salva Peir=F3 <speiro@ai2.upv.es>
Date: Tue, 17 Dec 2013 10:06:30 +0100

> The yam_ioctl() code fails to initialise the cmd field
> of the struct yamdrv_ioctl_cfg. Add an explicit memset(0)
> before filling the structure to avoid the 4-byte info leak.
>=20
> Signed-off-by: Salva Peir=F3 <speiro@ai2.upv.es>

Applied and queued up for -stable, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
