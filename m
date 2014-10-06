From: Felipe Balbi <balbi@ti.com>
Subject: Re: CPSW bug with AM437x SK
Date: Mon, 6 Oct 2014 09:33:38 -0500
Message-ID: <20141006143338.GC12392@saruman>
References: <20141003010418.GA9612@saruman>
 <543266F3.4090200@ti.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="aT9PWwzfKXlsBJM1"
Cc: <balbi@ti.com>, <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>,
	Linux ARM Kernel Mailing List
	<linux-arm-kernel@lists.infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <543266F3.4090200@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--aT9PWwzfKXlsBJM1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, Oct 06, 2014 at 03:24:59PM +0530, Mugunthan V N wrote:
> On Friday 03 October 2014 06:34 AM, Felipe Balbi wrote:
> > [  261.177168] [<c0648d48>] (skb_panic) from [<c0565edc>] (skb_put+0x5c=
/0x60)
> > [  261.184415] [<c0565edc>] (skb_put) from [<c0605aac>] (unix_stream_se=
ndmsg+0x164/0x390)
> > [  261.192712] [<c0605aac>] (unix_stream_sendmsg) from [<c055b364>] (so=
ck_aio_write+0xdc/0xfc)
> > [  261.201475] [<c055b364>] (sock_aio_write) from [<c014c42c>] (do_sync=
_write+0x8c/0xb4)
> > [  261.209697] [<c014c42c>] (do_sync_write) from [<c014cf70>] (vfs_writ=
e+0x118/0x1c0)
> > [  261.217652] [<c014cf70>] (vfs_write) from [<c014d564>] (SyS_write+0x=
4c/0xa0)
> > [  261.225054] [<c014d564>] (SyS_write) from [<c000ed40>] (ret_fast_sys=
call+0x0/0x48)
> > [  261.232988] Code: e58d4008 e58de00c e59f0008 ebfff48e (e7f001f2)=20
> > [  261.239378] ---[ end trace d64258d586f40104 ]---
>=20
> The BT shows that the warn came from a unix socket interface, so this
> cannot be a CPSW bug, its a bug in unix socket.
>=20
> Are you not seeing this issue with file system in any other media?

Have not tried with other media, but since it comes from vfs_write() and
my rootfs sits in NFS I figured "that might be the cause". Could not
reproduce this with BeagleBone Black, btw.

> I will try to reproduce this locally with my AM437x EVMsk.

alright.

--=20
balbi

--aT9PWwzfKXlsBJM1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUMqhCAAoJEIaOsuA1yqREIysP/AsA6ZF6jIIVVeOpsdKd7l3I
xuJtSffNjHsPP7n0WAXCAUlLNYeS2uHFyN5vSHhf3c7dVuF7WpSSzTMkDaUHPd8y
4V9BJQyf9D6g2ZnfwXy+GH0WH0nAXHSzk8qQnMnCM3VgSqmtEoT+x05hklqXyg4U
lZ3D337PAI5+CAGPOKPUYDtA5c4LReFsm2enrYLFl8mjqeTIWT0bboM+usfv21c/
fPKnTasIOGAzGrSGoubHcu7FFBvheEmpvRQ8NGg6U9ivaEsacedQ24R3oGvDyrPN
LGMSE8TQ0l8QxIbqIFEIr2mI7MZDdNeZF0M9EyQ1HXsseDlUVijmGiJUwB9OW/zH
wfacupD+gBgtUrLiWjftY9FSvNs1NvWysj9qRvKWoGExFJEKEKDdonfiGsY5o/i2
cfx2Oa5yXY36n00Mxnn46KvI/xkA31lnL0Bu/q58qciGZNrVYsG0OGK4GmLco1Y2
DfKPF6CzsNdXbSlGhGPGVrPkT1+nqqu7p5bvxzgta0fT3PHrza36cpgQdrim2bXX
a9fC2+QWvPwC1j9OW38uSyQoclxUjYnZxYYTt6VWZCFqeriztCQPDsnfLxCV+mWs
R0Mv8kENGZ3pV1FnXZ9RYjnjmhclQ68uMXLR8xKf54krveeM+Dqa6bFRalbmidlr
2nvJ+CwyTSiz/294GCsj
=VAWl
-----END PGP SIGNATURE-----

--aT9PWwzfKXlsBJM1--
