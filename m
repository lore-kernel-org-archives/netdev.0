From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth 2015-07-02
Date: Thu, 2 Jul 2015 10:30:38 +0300
Message-ID: <20150702073038.GA25214@t440s.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DocE+STaALJfprDB"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

A couple of regressions crept in because of a patch to use proper list
APIs rather than manually reading & writing the next/prev pointers
(commit 835a6a2f8603237a3e6cded5a6765090ecb06ea5). Turns out this was
masking a few bugs: a missing INIT_LIST_HEAD() call and incorrectly
using list_del() rather than list_del_init(). The two patches in this
set fix these, and it'd be nice they could still make it to 4.2-rc1 to
avoid new bug reports from users.

Please let me know if there are any issues pulling. Thanks.

Johan

--
The following changes since commit 011cb197a84ed547c2b6b12a86adbeec1be0fdaf:

  Merge branch 'bnx2x' (2015-06-25 06:30:43 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to ab944c83f6690df0c7f67e6bcc29fc0c82ef6021:

  Bluetooth: Reinitialize the list after deletion for session user list (2015-06-30 21:46:19 +0200)

----------------------------------------------------------------
Tedd Ho-Jeong An (2):
      Bluetooth: hidp: Initialize list header of hidp session user
      Bluetooth: Reinitialize the list after deletion for session user list

 net/bluetooth/hidp/core.c  | 1 +
 net/bluetooth/l2cap_core.c | 4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

--DocE+STaALJfprDB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVlOieAAoJECQj9vv5qNQSiiYP/1osk3CxItxSgCxN2Obq7Xlf
0/fXWb3P1r+cbZP2REyBU7wZWlmN7imAZ9j3Zr1MUqJIf3+fmtrPARg7yEe+/sal
ry4VS01OJDFdI4DKAMFEhtC/YdIqQ2Kbfucq2wqe4CrMVhkWIyo5qkMZ2Kha79oM
gYcuHoWzDmLnHxcK7lGyaM5qdJxhk6FUUFiAwAZLTrfSfn5+atxzfsWZZRwZqBq1
bygCkII3QEeTkjWFLGUCA9s/GttcQI8DMEiZoKrDlSJCF+ePTBG4h20+9YGBK3K9
lYcOpWEEbYvQv3MohJXh4tysNbPanZBZa4tx4vOAyM+F1TE9SFVCOmvjmxTKKT9S
tQLiRae+SwkRqpBeiN5c30atzltBsStRRQ6mIZeomqJR3uwILtMhgaodBRXitAME
kCEF3+wfzyxIBLe4qWNUSB5cq3UYFHSEC6BfSk7sd+DpHV3CmBD7JuWDkeYzvHAn
v7IVpITlEXdgek2cBw7DR/xaE96HhgNpDB9upEhuPvSsAjEkgWc/XCxG9cF9becx
q0+H4kHyT9pui9j0u4XOW7BjFImFDR3QQklwq0luiY2GC9e/aW2lpyGHDpFpkDWo
jCd5Pajz4gPfal2fHwd0dnz8Pjl5OxzkYY1ms8UyllsL8QkEsLVSVZXQHO++oJOr
Vu1PlTAal8qUypnf+P2I
=b/ol
-----END PGP SIGNATURE-----

--DocE+STaALJfprDB--
