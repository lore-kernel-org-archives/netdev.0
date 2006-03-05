From: Michael Buesch <mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org>
Subject: Please pull bcm43xx softmac-upstream and dscape-upstream branches
Date: Sun, 5 Mar 2006 21:47:55 +0100
Message-ID: <200603052147.55557.mbuesch@freenet.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart8924693.qtzRLS577B";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

--nextPart8924693.qtzRLS577B
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi John,

It took a little longer than promised, but a broken harddisk in
my server delayed my plans. ;)

Please pull branches "softmac-upstream" and "dscape-upstream"
from my repository at:
git://bu3sch.de/wireless-2.6.git

This introduces the following changesets:
Michael Buesch:
      bcm43xx-d80211: Partially fix PIO code. Add Kconfig option for PIO or=
 DMA mode (or both).
      bcm43xx-d80211: fix typo. Missing D80211.
      bcm43xx-d80211: add note that not all devices support PIO.
      bcm43xx-d80211: Documentation fix by "Bin Zhang" <yangtze31-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
      bcm43xx-d80211: completely disable wireless_handlers, as we must not =
override d80211 handlers.
      bcm43xx-d80211: Move sprom lowlevel reading/writing to its own functi=
ons.
      bcm43xx-d80211: make bcm43xx_sprom_crc() static.
      bcm43xx-d80211: remove all remaining standard WX.
      bcm43xx-d80211: split channel helper functions, so that they can be c=
alled without a valid running core.
      bcm43xx-d80211: remove old unused struct.
      bcm43xx-d80211: Completely remove all WX and add a sysfs interface as=
 substitute for the private WX.
      bcm43xx-d80211: rewrite and simplify the periodic task handling.
      bcm43xx-d80211: Fix Kconfig typo (transfer mode default)
      bcm43xx-d80211: use -Dwext for wpa_supplicant.
      bcm43xx-d80211: Don't build add_sta, if it already exists.
      bcm43xx-d80211: Workaround init_board vs IRQ race.
      bcm43xx-d80211: move initialized =3D 1 to the end of init_board.
      bcm43xx-d80211: Remove obsolete FIXME on wireless_handlers.
      bcm43xx-d80211: Move TX/RX related functions to its own file. Add bas=
ic RTS/CTS code.
      bcm43xx-d80211: fix typo in comment.
      bcm43xx-d80211: properly register device attributes at the right plac=
e.
      bcm43xx-d80211: remove magic add_sta.c and add the STA interface thro=
ugh sysfs.

Michael Buesch:
      bcm43xx: Move sprom lowlevel reading/writing to its own functions.
      bcm43xx: make bcm43xx_sprom_crc() static.
      bcm43xx: split the channel helper functions, so that they can be used=
 without a valid running core.
      bcm43xx: remove old unused struct.
      bcm43xx: Fix Kconfig typo (transfer mode default)
      bcm43xx: Workaround init_board vs IRQ race.
      bcm43xx: move initialized =3D 1 to the end of init_board.
      bcm43xx: add assert(bcm->initialized) to periodic_tasks_setup().
      bcm43xx: Move TX/RX related functions to its own file. Add basic RTS/=
CTS code.
      bcm43xx: Add sysfs attributes for device specific tunables.

If you want to look at the individual patches, please use
my git webinterface, as the patch would be to big to inline here.
http://bu3sch.de/git?p=3Dwireless-2.6.git;a=3Dsummary

=2D-=20
Greetings Michael.

--nextPart8924693.qtzRLS577B
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBEC057lb09HEdWDKgRAi4GAKCxix+I8uUF6FUmyYQxn8J4t/ExhgCdHE/W
Y8KdLJhaYIaexkxiyEhNacI=
=lyv0
-----END PGP SIGNATURE-----

--nextPart8924693.qtzRLS577B--
