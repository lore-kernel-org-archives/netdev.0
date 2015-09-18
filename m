From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/8][pull request] Intel Wired LAN Driver Updates
 2015-09-17
Date: Thu, 17 Sep 2015 18:00:52 -0700
Message-ID: <1442538052.2911.7.camel@intel.com>
References: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+Hgb9asyq/JfM4jIgxsn"
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:22138 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752347AbbIRBBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 21:01:07 -0400
In-Reply-To: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+Hgb9asyq/JfM4jIgxsn
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
>=20
> ---
> Waiting for Dave to update his net-next tree before pushing this
> series
> to my next-queue tree.
>=20
> The following are changes since commit
> 9adbac599a71bc25a2617850ffcaa4388dc5c20d:
>   fm10k: fix iov_msg_mac_vlan_pf VID checks
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
> master

This series has been pushed up to my tree now.
--=-+Hgb9asyq/JfM4jIgxsn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJV+2JEAAoJEOVv75VaS+3Om2IP+QEsno07CYrPGYty+KGxghjn
vUy8ojwT8GWgyt1aqsi7vcwzssZULqq2pl1rn9gTgamc65ExYm0UN1ncV7v3KwXP
PE2yzPaZXuT2aj2DEibQskNRPj1Y13ntDRnx9m1XBy2dGBhhVViAkO+vmZEkXDGI
ZDjGCOspQqWakwIWg7QtaSr5Sk2UGArQeQruHPT+gdW7Yy3k5whDlpKapMMVtVUV
kyYDnCz1yw2W+2eqEp2US5pG2Dn9k1eSDBSPmmSRXHzHnFFrRvjyJ2MMjb6ovfjG
IkBoDyVSg/OQdA5VK3eTEroaY91WmYGeAZFEVWp7aSFmkls2QgLwqfjFgyxIAu5T
3aOE6spaymojGdooFUJ25UHoJAk0T/boVSKc5XligViMpxtAo+xKRwHln1w6V1rQ
yoDMJHuSWeNBj+tBlU2C5+M4sORT7BvillOqBzMsHZB3FMI+P5l6sECRVi69hTZb
TFeSZnhw/e82fj601OjNtRbZ/IuESSA+/YSk/wyqIDdoHdtpzCqGhpuv63gXePRq
ZhH7rRktYArzQTd8XeDBvlJuiQPI7XItoVWGUlUuuiCEQXg29hrHzjGLepLEsu4t
HJnO69A7fsvEu0goNOG+VM9sLrmICrmRA+CaR58mC8YUmQxe8Dcsm4ghaZBF8RdU
uyt9B0ONAiSWZtyYyXK7
=S8Qz
-----END PGP SIGNATURE-----

--=-+Hgb9asyq/JfM4jIgxsn--
