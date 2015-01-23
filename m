From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: net: prevent of emerging cross-namespace symlinks patches for
 3.14?
Date: Fri, 23 Jan 2015 12:14:48 +0000
Message-ID: <20150123121448.GA2543@charon>
References: <54B6E36F.9060703@xs4all.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	"Alexander Y. Fomichev" <git.user@gmail.com>,
	David Miller <davem@davemloft.net>
To: Miquel van Smoorenburg <mikevs@xs4all.net>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54B6E36F.9060703@xs4all.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 14, 2015 at 10:45:19PM +0100, Miquel van Smoorenburg wrote:
> [first sent to lkml, now to netdev and the original patch author]
>=20
> When running 'lxc' on the latest -stable kernel, 3.14.28, I'm seeing =
these
> errors:
>=20
> Jan 14 17:47:16 lxc2 kernel: [   10.704890] WARNING: CPU: 0 PID: 3209=
 at
> fs/sys
> fs/dir.c:52 sysfs_warn_dup+0x8c/0xb0()
> Jan 14 17:47:16 lxc2 kernel: [   10.704892] sysfs: cannot create dupl=
icate
> filename '/devices/virtual/net/eth0.104/upper_eth0'
> Jan 14 17:47:16 lxc2 kernel: [   10.704954] CPU: 0 PID: 3209 Comm:
> lxc-autostart Not tainted 3.14.28-xsserver #1
>=20
> I did not see these errors in 3.12. This was fixed in 3.17 by:
>=20
> net: prevent of emerging cross-namespace symlinks
> https://github.com/torvalds/linux/commit/4c75431ac3520631f1d9e74aa884=
07e6374dbbc4
>=20
> net: fix creation adjacent device symlinks
> https://github.com/torvalds/linux/commit/7ce64c79c4decdeb1afe0bf2f6ef=
834b382871d1
>=20
> These patches apply cleanly to 3.14.28.
>=20
> If you agree that this should go into 3.14-stable, please ack.
>=20

Thank you, I am queuing these 2 patches for the 3.16 kernel as well.

Cheers,
--
Lu=EDs

> Thanks,
>=20
> Mike.
> --
> To unsubscribe from this list: send the line "unsubscribe stable" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
