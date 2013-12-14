From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2013-12-14
Date: Sat, 14 Dec 2013 22:57:32 +0000
Message-ID: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="=-CEstu7AclkbRaDsePtj6"
Cc: netdev <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17181 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753697Ab3LNW5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 17:57:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-CEstu7AclkbRaDsePtj6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit f52d81dc27c3456c702e83183035142c222acdc7=
:

  ipv6: fix compiler warning in ipv6_exthdrs_len (2013-12-14 02:01:27 -0500=
)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

for you to fetch changes up to bbbe7149bf0bd14432373de39315505e7a133acc:

  sfc: Remove unnecessary condition for processing the TX timestamp queue (=
2013-12-12 22:07:18 +0000)

1. Change PTP clock name to 'sfc'.
2. Complete support for hardware timestamping and PTP clock on the
SFC9100 family.
3. Various cleanups for the PTP code.

Ben.

Ben Hutchings (10):
      sfc: Store flags from MC_CMD_DRV_ATTACH for later use
      sfc: Do not use MAC address as clock name
      sfc: Initialise efx_ptp_data::phc_clock_info from a static template
      sfc: Remove kernel-doc for efx_ptp_data fields not present in this ve=
rsion
      sfc: Copy RX prefix into skb head area in efx_rx_mk_skb()
      sfc: Store VPD serial number at probe time
      sfc: Associate primary and secondary functions of controller
      sfc: Enable PTP clock and timestamping for all functions on EF10
      sfc: Don't clear timestamps in efx_ptp_rx()
      sfc: Remove unnecessary condition for processing the TX timestamp que=
ue

Daniel Pieczko (1):
      sfc: split setup of hardware timestamping into NIC-type operation

Jon Cooper (1):
      sfc: Add RX packet timestamping for EF10

Laurence Evans (3):
      sfc: PTP - tidy up unused/useless variables
      sfc: Tidy up PTP synchronization code
      sfc: Add support for SFC9100 timestamp format

 drivers/net/ethernet/sfc/ef10.c       |  128 +++++++-
 drivers/net/ethernet/sfc/efx.c        |  117 ++++++-
 drivers/net/ethernet/sfc/falcon.c     |    2 +
 drivers/net/ethernet/sfc/mcdi.c       |   25 ++-
 drivers/net/ethernet/sfc/mcdi.h       |    2 +
 drivers/net/ethernet/sfc/net_driver.h |   53 +++-
 drivers/net/ethernet/sfc/nic.h        |   12 +
 drivers/net/ethernet/sfc/ptp.c        |  594 +++++++++++++++++++++++------=
----
 drivers/net/ethernet/sfc/rx.c         |   12 +-
 drivers/net/ethernet/sfc/siena.c      |   69 +++-
 10 files changed, 797 insertions(+), 217 deletions(-)

--=20
Ben Hutchings
Knowledge is power.  France is bacon.

--=-CEstu7AclkbRaDsePtj6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQEVAwUAUqziXGkILBsOca60AQpS+ggAu/PyJICrSkdHWOw/WfYV3bWAWV7PsN5y
GMaLdME/tks5q9P45hJMd2byxwy+W+xcRgmSgm0M+fSmmIkwr64C/+rgwRC9UBHe
bPSrGyQIBsXvnGEJQj15q+3XCGK/iEBUMBWsO3KK6aNkiUWWKZjU3yGCGJFCQyrr
SCZqRPcLY/QFrIKBWlsevRpXPv3XgNJ8DjV8dzSy/tAuO61VsrMU25kj7t9AA0Hw
3WrJ6UcuQwlw4YNxLOQ16HfT+275qr9+x4tH1DYSV4ZAy4ERLdEl1TgNzVlgb9nf
CWNdl5omS8vFRoW+7bIPRwlv/LYjcNIeZ+cjaglrJ8KnuAQTaiqHlw==
=cIw5
-----END PGP SIGNATURE-----

--=-CEstu7AclkbRaDsePtj6--
