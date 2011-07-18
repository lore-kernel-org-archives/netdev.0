From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] include/linux/sdla.h: remove the prototype of sdla()
Date: Mon, 18 Jul 2011 11:06:17 -0700 (PDT)
Message-ID: <20110718.110617.207141326101677046.davem@davemloft.net>
References: <CAM_iQpWDrhHw8-Hf4q1miHR+rT33wQb=ZSb=ffsxaSak=UHPMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mmarek@suse.cz, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpWDrhHw8-Hf4q1miHR+rT33wQb=ZSb=ffsxaSak=UHPMw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Am=E9rico Wang <xiyou.wangcong@gmail.com>
Date: Sun, 17 Jul 2011 16:22:20 +0800

> `make headers_check` complains that
>=20
> linux-2.6/usr/include/linux/sdla.h:116: userspace cannot reference
> function or variable defined in the kernel
>=20
> this is due to that there is no such a kernel function,
>=20
> void sdla(void *cfg_info, char *dev, struct frad_conf *conf, int quie=
t);
>=20
> I don't know why we have it in a kernel header, so remove it.
>=20
> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

Applied, thanks.
