From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/8][pull request] Intel Wired LAN
	Driver Updates
Date: Thu, 05 Sep 2013 22:58:38 -0700
Message-ID: <1378447118.2048.64.camel@jtkirshe-mobl>
References: <1378446228-13815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7844194544654017172=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1378446228-13815-1-git-send-email-jeffrey.t.kirsher@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============7844194544654017172==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tRDVbvikdp8WYz5Fkbo+"


--=-tRDVbvikdp8WYz5Fkbo+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-09-05 at 22:43 -0700, Jeff Kirsher wrote:
> This series implements the new i40e driver for Intel's upcoming
> Intel(R) Ethernet Controller XL710 Family of devices.
>=20
> V1: initial send
> V2: each patch has individual comments, in general, feedback from the
>     list was applied and addressed. Many changes due to internal
> review
>     and coding as well.
> V3: many more individual comments addressed, thanks reviewers!  Many
>     other changes due to internal review and development.
> V4: addresses remaining community comments, mostly trivial edits.
>     major sparse based cleanup of possible endian issues
>     removal of most of __func__ references
>     sizeof(*var) instead of sizeof(struct ...)
>     change 'NULL =3D=3D' tests to !NULL
>     implement xps
>     use kernel bitshift macros (upper_32_bits, etc)
> V5: remove sysfs support from this set, will rearchitect
>     changes from community comments
>=20
> Let me start by saying thanks and we appreciate any time spent by
> those of you who review and comment on this new driver, and we will
> attempt to address and respond to all issues brought to our attention.
>=20
> Jesse tried to break the patches up to ease review, but the series
> should
> apply and still be bisectable, as the last patch adds the driver to
> the kernel compile with CONFIG_I40E.
>=20
> This driver is for a brand new bit of silicon that has a different
> design than other Intel Ethernet silicon, and therefore needed a new
> driver.
>=20
> The hardware has quite a bit of capability and this driver is only
> meant to provide basic functionality at first.  Future patches will
> continue to add functionality and bug fixes.
>=20
> This initial release is very early in the product cycle with the
> intent
> of getting initial support into the kernel before users have the
> hardware available to purchase.  A software development manual is not
> ready yet but will be available when the hardware ships.
>=20
> To be clear, the driver development model and interaction with
> community submitted patches *will not be any different* than what
> we are currently doing today.
>=20
> This driver *does* use some code (as our previous drivers do) that is
> meant to be shared to different OS drivers.  One of the following
> patches has the majority of this code in it, and is clearly called out
> in the commit message.
>=20
> An associated i40evf driver has been posted for review.
>=20
> List of tools we ran in preparation:
> way more sparse clean
> make W=3D1, W=3D2 clean
> checkpatch (almost) clean
>         total: 1 errors, 4 warnings, 30595 lines checked
>         NOTE: Ignored message types: LONG_LINE
>         - issues have been addressed and the remainders
>           are noise.
> codespell clean
> smatch (almost) clean with a couple minor warnings
> coccicheck clean
> namespacecheck clean
> allmodconfig clean
> ppc64 build clean (unable to test yet)
>=20
> This driver is a team effort, thank you to Joseph Gasparakis,
> Shannon Nelson, Anjali Singhai-Jain, Mitch Williams, Neerav
> Parikh, Vasu Dev, Kavindya Deegala, Yi Zou, and PJ Waskiewicz.
>=20
> TODO (known issues)
> BQL implementation
> finish rtnl_stat64 locking (we have a patch but debugging it)
>=20
> The following are changes since commit
> 2e032852245b3dcfe5461d7353e34eb6da095ccf:
>   Merge branch 'for-linus' of
> git://git.linaro.org/people/rmk/linux-arm
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
> master
>=20
> Jesse Brandeburg (8):
>   i40e: main driver core
>   i40e: transmit, receive, and NAPI
>   i40e: driver ethtool core
>   i40e: driver core headers
>   i40e: implement virtual device interface
>   i40e: init code and hardware support
>   i40e: debugfs interface
>   i40e: include i40e in kernel proper

Grrr... I sent v5 out and forgot to note it in the title.  Sorry for the
spam, I will resend with the proper titles. :-(

--=-tRDVbvikdp8WYz5Fkbo+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSKW8OAAoJEOVv75VaS+3O660P/ijElkGur/Yn1yoesuYQN9Yp
+MhagxuGszGWEty9J1ZODzVSUlCPjn2YMXSAu/qLiXeIOVDG/9attAtAAERumt3m
gy4g8p2D8oku3KPx5SwqnvXzyvDYZOLTeM4IQpe9dZo3O4U+WfWB1QNuoxa/ESrh
O0MXsv2dsOaNzd2iRILoRKwWMJfmADWyKnJmxcVomnPUtPaNPX/lQRhKeOobwv1h
jDQHqaRuP5x08qJytNQeXJ49pKrDwHNwwZlk72+iaWWtGznzlD7X+fjtqgPLWDar
wdvTpFI/R9nsZtOs+qqA+4JOGem19NSPheFruru5P8kFb/pqOmaUfrcYZZY+nBCO
eIirDEHhpSmfpz2b3QXLPxOYNJQ1vsdgwpUfUhu0FuSh5ajovB82lrnConczASY8
mgsgC8FBLoi2GNSyEGuYapQRum2vgjl95Ls4VsbqLUhPNDmXxnvAqrrnvOv5vBqt
Lctq0H5Efow2B3vImhQXtZPPRVGdLZCLKauvcJzIVpbPZGesUs7x10PD8/AOqmSU
c+VKyCz5K/UhXyBozD/bcMbhFLEZrJIpwSXBgDPVFeBiCa79pZIxioA15c2c7iE8
BlIqzRw7HkisPZOmI/1ubxvGMPSMapxKoD6alDoQwXSOcOBuskqlWFtN324RTjvz
mMPxdFekYCSMYOHVRTHm
=jOxB
-----END PGP SIGNATURE-----

--=-tRDVbvikdp8WYz5Fkbo+--



--===============7844194544654017172==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Learn the latest--Visual Studio 2012, SharePoint 2013, SQL 2012, more!
Discover the easy way to master current and previous Microsoft technologies
and advance your career. Get an incredible 1,500+ hours of step-by-step
tutorial videos with LearnDevNow. Subscribe today and save!
http://pubads.g.doubleclick.net/gampad/clk?id=58041391&iu=/4140/ostg.clktrk
--===============7844194544654017172==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============7844194544654017172==--
