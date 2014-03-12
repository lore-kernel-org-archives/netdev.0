From: Martin Pitt <martin.pitt@ubuntu.com>
Subject: Re: [mac80211_hwsim] BUG: unable to handle kernel paging request at
 ce1db404
Date: Wed, 12 Mar 2014 18:08:06 +0100
Message-ID: <20140312170806.GC2983@piware.de>
References: <20140305125703.GA7193@localhost>
 <20140305132317.GB10880@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="/NkBOFFp2J2Af1nK"
Cc: Johannes Berg <johannes.berg@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140305132317.GB10880@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--/NkBOFFp2J2Af1nK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hey Fengguang,

Fengguang Wu [2014-03-05 21:23 +0800]:
> git bisect start v3.10 v3.9 --
> git bisect  bad ff89acc563a0bd49965674f56552ad6620415fe2  # 03:01      0-=
      2  Merge branch 'rcu/urgent' of git://git.kernel.org/pub/scm/linux/ke=
rnel/git/paulmck/linux-rcu
> git bisect  bad 24d0c2542b38963ae4d5171ecc0a2c1326c656bc  # 03:03      0-=
      2  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/viro/vfs
> git bisect good 151173e8ce9b95bbbbd7eedb9035cfaffbdb7cb2  # 03:11     20+=
     20  Merge tag 'for-v3.10' of git://git.infradead.org/battery-2.6
> git bisect  bad e95893004104054d49406fd108fefa3ddc054366  # 03:13      0-=
      4  Merge tag 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/mst/vhost
> git bisect good 8a72f3820c4d14b27ad5336aed00063a7a7f1bef  # 03:19     20+=
     20  Merge git://git.kernel.org/pub/scm/linux/kernel/git/cmetcalf/linux=
-tile
> git bisect  bad 600fe9751aeb6f6b72de84076a05c5b8c04152c0  # 03:21      0-=
      5  ipc_schedule_free() can do vfree() directly now
> git bisect  bad 126de6b20bfb82cc19012d5048f11f339ae5a021  # 03:23      0-=
      1  linkage.h: fix build breakage due to symbol prefix handling
> git bisect good 251df49db3327c64bf917bfdba94491fde2b4ee0  # 03:27     20+=
     20  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/dtor/input
> git bisect  bad 73287a43cc79ca06629a88d1a199cd283f42456a  # 03:29      0-=
      2  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
> git bisect good 953c96e0d85615d1ab1f100e525d376053294dc2  # 03:37     20+=
      0  tg3: Use bool not int
> git bisect  bad 4fc4118cdb29ab946b8a586fc766ebb6ae1e1c90  # 03:39      0-=
      2  wil6210: more Rx descriptor accessor functions
> git bisect good e73dcfbf061b524fe9aaef56cf3c2e234a45ec19  # 03:46     20+=
      7  Bluetooth: hidp: fix sending output reports on intr channel
> git bisect good d5590bba37f3c7d496195648532d5313abb43891  # 03:50     20+=
      0  NFC: pn533: Re-group fields in struct pn533
> git bisect  bad 06d961a8e210035bff7e82f466107f9ab4a8fd94  # 03:52      0-=
      7  mac80211/minstrel: use the new rate control API
> git bisect  bad 97990a060e6757f48b931a3946b17c1c4362c3fb  # 03:54      0-=
      3  nl80211: allow using wdev identifiers to get scan results
> git bisect  bad 85220d71bf3ca1ba9129e0744247ae5f61bec559  # 03:56      1-=
      5  mac80211: support secondary channel offset in CSA
> git bisect  bad 0ca54f6c5fd4ce58aa044d1fc7f00d7f6cf2801c  # 03:57      1-=
      6  mac80211: provide SSID in IBSS mode
> git bisect  bad 3088f7d2db42925808c4b43a6258647ee4d1dd5f  # 03:59      3-=
      8  mac80211: stringify another plink state
> git bisect  bad 9d6d6f4924133567a108a862d9cf949cd03f71cb  # 04:02      0-=
      2  mac80211: unset FC retry bit in mesh fwding path
> git bisect  bad 9ea927748ced4953f1e9a0f1fa1fdeacd1018b4e  # 04:05      0-=
      9  mac80211_hwsim: Register and bind to driver
> # first bad commit: [9ea927748ced4953f1e9a0f1fa1fdeacd1018b4e] mac80211_h=
wsim: Register and bind to driver
> git bisect good ddc4db2e3d5393ede7a9222bb3b7522a603a4678  # 04:27     69+=
     18  mac80211: make ieee802_11_parse_elems an inline
> git bisect  bad b148a42ba7823e34971cd4e5b05a5c74fa3311ed  # 04:27      0-=
     19  Add linux-next specific files for 20140228
> git bisect  bad d8efcf38b13df3e9e889cf7cc214cb85dc53600c  # 04:30      0-=
      3  Merge tag 'for-linus' of git://git.kernel.org/pub/scm/virt/kvm/kvm
> git bisect  bad b148a42ba7823e34971cd4e5b05a5c74fa3311ed  # 04:30      0-=
     19  Add linux-next specific files for 20140228

I noticed that this bisect list didn't include Sasha Levin's followup fix:

  http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/dri=
vers/net/wireless/mac80211_hwsim.c?id=3Dc07fe5ae06

That was supposed to fix problems at registration. Is that actually
inclued in your bisection? I suppose it is, but it's quite clear that
with only 9ea927 you'd get crashes with building it statically.

I have no real idea why ieee80211_register_hw() would fail (but then
again, I'm a kernel n00b). It's apparently related to doing
platform_driver_register() before, so perhaps it's missing another
field in the struct. "unable to handle kernel paging request", is that
a normal error message if a driver fails to initialize? I would have
assumed that the kernel would't panic if a single driver fails to
initialize. Or does that mean it actually tries to access uninit'ed
memory?

I can certainly check out linux-next, build the whole thing
statically, and try to twiddle things a bit, but I'm afraid that's
just going to take a while (both because this is all new to me and I'm
working on other things ATM), so please don't hold your breath. :-)

Thanks,

Martin
--=20
Martin Pitt                        | http://www.piware.de
Ubuntu Developer (www.ubuntu.com)  | Debian Developer  (www.debian.org)

--/NkBOFFp2J2Af1nK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCAAGBQJTIJR2AAoJENFO8V2v4RNHpRwQAKRoXwxWn+/FLB77kaC9F1tn
89Hg251cg+YBoeEsz601Qr8IABwWSGKjn+IzfnbrrWk+euD/7Q/hnYQ0W2XOSDpn
1EWb+PkucKScGZebURbrd0/9MPStABq+/WO4iCrV6htIQIRMdRv3sE8CU3IqtR9H
n9hCifWnYedKRHN6edVhbNBqN8FERCjrUyEjJY/z3jgOQ8ItecQZbdK/A8pxyAmn
CcPU24A9xMUnP0JuHYZjvaVfdJco7dm51K2uTZDGVys0nLi+HOzR5V+i3hvgkMzd
SXNvMxehZlaxEUxpT3cUl2ClM9Qu5FkWhRHMXEj8MOMWhn2iMB4RaiDi2j8ZXeMs
S/b1VkON+zllgptHctK04sX7c6TIvE0wUlRtAxqAKf+KHa4ohiGsZ3np8R+aUnBJ
dxpxjrE3jpoCOrCFSWAuy+EOvntLuUOKmqmQ52r3Qe7B3gpZRnC44oq0Mpj52t0y
ImKvrd+UyYNTaDSKR+xfzU7BUiDD5Rul0gUbj/3RFF8Ile3LekTj3ao/lRjNTIlY
2wz5Y3t2qeD0sXKIzypxYQI7rd/Fhx7USE8aGAo0P2YDsSghgVbYKQXV/84s/EDP
3azM8MJiSeYqRwK/QdrYHka53wvYn8/A7nNRSQ0+b+yQ8aKFCQ/aD4/+g/cwC0r8
CYI0LYOFYyOIyf1mJBEH
=8hmB
-----END PGP SIGNATURE-----

--/NkBOFFp2J2Af1nK--
