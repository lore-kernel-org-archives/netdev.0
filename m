From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/8][pull request] Intel Wired LAN Driver Updates
 2015-09-17
Date: Fri, 18 Sep 2015 09:58:04 -0700
Message-ID: <1442595484.2873.5.camel@intel.com>
References: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-DQUN/7ZaiEeoEkwnVO1T"
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20741 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753305AbbIRQ6F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2015 12:58:05 -0400
In-Reply-To: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DQUN/7ZaiEeoEkwnVO1T
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-09-17 at 17:17 -0700, Jeff Kirsher wrote:
> This series contains updates to i40e and i40evf.
>=20
> Shannon provides updates to i40e and i40evf to resolve an issue with
> the
> nvmupdate utility.  First renames a variable name to reduce confusion
> and
> to differentiate it from the actual user variable.  Then added the
> ability
> to save the admin queue write back descriptor if a caller supplies a
> buffer for it to be saved into.  Added a new GetStatus command so
> that
> the NVM update tool can query the current status instead of doing
> fake
> write requests to probe for readiness.  Added wait states to the NVM
> update state machine to signify when waiting for an update operation
> to
> finish, whether we are in the middle of a set of write operations, or
> we
> are now idle but waiting.  Then added a facility to run admin queue
> commands through the NVM update utility in order to allow the update
> tools to interact with the firmware and do special commands needed
> for
> updates and configuration changes.  Also added a facility to recover
> the
> result of a previously run admin queue command.

To add, this series adds necessary capability to the driver to extend
the nvmupdate utility to be compatible with the latest released
adapters.  Without it, the already released nvmupdate utilities won't
work.
--=-DQUN/7ZaiEeoEkwnVO1T
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJV/EKcAAoJEOVv75VaS+3OJGoQAKF6uaT96NlOp0h3aHOymFc/
lcNZCxo1o4hwI+uti9fMdaQV+NPDiwH+Zv2rWvG7z5EBAe3WfiTW29zd9zioiuTc
4MdXQIoqLw2GtGDAUgh3VlU7xdjYKP7pwDDwQ0m8cXEQzuIiMU7ae0VSxYFuvloS
NfN+3MC/Gq7TQ/Ji55SU/mWv5rOYIwP7GcaZ43z/3dgnLuvNxe2yP//BxWvQswtb
n/oVD12BPDrAaStSsAAwRSKEsnVtPR3P2tA5FWqFPBPRgnJOWhRL5cDAw3+fc5Tw
ORR+WCqecwe2j1cnbW5GjX4N3qvzjJa4c0qMRj69nK34/xEGpOHF1bhFM/yjbJXO
/oVgPEAmuXrepAf9vufPHOhau2lWOPxHiQaZj+kB4yA9wgjlzYIggE/CZFEIM1vu
l+reTrK4hbBBjKrPRgqU9A2MYcsb28mTIMZ49VousfxHWrrH5XHfyzpieg/96XKJ
dG20Y6SbAWeFr7laDwCLg3ZNTFXQcrc8ydG4FHJiB1/+qPdwhQqTmWagCecO5Q27
tYl9GR42Rb6y+IeWWDaQuYR9JusrBFA5ALXKL/Yq/JaJCr2LDGRF9hZPRCHiBPyc
UGX5freFGE/8hVUZnLAGzWyvDo/KyxW8hB2j6ioSQ7FA52zWaa8q/63DeqwmY+gv
eXRug+E29UjHiSWu/iu8
=T7e1
-----END PGP SIGNATURE-----

--=-DQUN/7ZaiEeoEkwnVO1T--
