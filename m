From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth 2015-10-16
Date: Fri, 16 Oct 2015 17:29:00 +0300
Message-ID: <20151016142900.GA22587@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cNdxnHkX5QqsyA0e"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:34408 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbbJPO3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 10:29:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

First of all, sorry for the late set of patches for the 4.3 cycle. We
just finished an intensive week of testing at the Bluetooth UnPlugFest
and discovered (and fixed) issues there. Unfortunately a few issues
affect 4.3-rc5 in a way that they break existing Bluetooth LE mouse and
keyboard support.

The regressions result from supporting LE privacy in conjunction with
scanning for Resolvable Private Addresses before connecting. A feature
that has been tested heavily (including automated unit tests), but sadly
some regressions slipped in. The UnPlugFest with its multitude of test
platforms is a good battle testing ground for uncovering every corner
case.

The patches in this pull request focus only on fixing the regressions in
4.3-rc5. The patches look a bit larger since we also added comments in
the critical sections of the fixes to improve clarity.

I would appreciate if we can get these regression fixes to Linus
quickly. Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 53ca376eec4eb635e2249c8e89093f499e180731:

  mlxsw: core: Fix race condition in __mlxsw_emad_transmit (2015-10-15 06:03:06 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to 5157b8a503fa834e8569c7fed06981e3d3d53db0:

  Bluetooth: Fix initializing conn_params in scan phase (2015-10-16 09:24:41 +0200)

----------------------------------------------------------------
Jakub Pawlowski (2):
      Bluetooth: Fix double scan updates
      Bluetooth: Fix initializing conn_params in scan phase

Johan Hedberg (4):
      Bluetooth: Fix reference counting for LE-scan based connections
      Bluetooth: Fix LE reconnection logic
      Bluetooth: Fix remove_device behavior for explicit connects
      Bluetooth: Fix conn_params list update in hci_connect_le_scan_cleanup

 net/bluetooth/hci_conn.c  | 99 +++++++++++++++++++++++++++++++++-------------
 net/bluetooth/hci_core.c  |  7 ----
 net/bluetooth/hci_event.c | 11 ++++--
 net/bluetooth/mgmt.c      | 24 +++++++++--
 4 files changed, 99 insertions(+), 42 deletions(-)

--cNdxnHkX5QqsyA0e
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWIQmsAAoJECQj9vv5qNQSDCYP/A7UMUc8HeZxGxZIhUkFtZIi
TOgjf9XBVNMlCrUnEc70y+5voMJPMRMOH3Hx1IcocBbyUAHuYFciWtBOGwbeADXT
ARFqmJ6nmxE8GKpxdt931xWYpXpaf779L6FCBhS8bvhjFV1QWg6XihVKeibTkZJc
XZZISKYf/Qfcely7tTgxBWiYZdeAaEAV6kp6yMN2x0lE6YjGzNjolabgrMrbqRY9
dN807qVjmgyrBGayQlHdLFwDfPnQ8ePJKGo6rfzRGVvxxvzQx41Iopy3XO9h76Td
juTfEzW6/BCm8nhL5IsIhB1uuK9Dy/SQVExECPzK+muqThuw+4shuGHTPqrxg6ot
vLLdtdoIuZJ+T2kXvNaLoVvuEkPkY3pVncShPZck6V5hyiOhw21oQNny31IpY3Jg
Y1VTlJXjlUjwbl5jGEA83eaVm7EuWqgQSdbbj1VJD3ViL19oarYUJ6XiwyjAPRh5
mZ+Vnob1IROcNviYI4krN05oPzEfesfTMYWVoL0n0hYKzLpyY7Tr+73ACeFdvpme
CzcsWk21dmrPgc0i6RCp6ZxvpOdcec39OmMSDxI2RbIX8E1+Ch7ecw4iT0M/WjwW
HCsiY4bJ7Vlbp2BZSncqM0F8jiBSZ0X5YZNjDJITOr8i2BDeyCBPP0YCrmMzUOE7
W8ii6WQCtZuG+YxEbvYY
=lYiM
-----END PGP SIGNATURE-----

--cNdxnHkX5QqsyA0e--
