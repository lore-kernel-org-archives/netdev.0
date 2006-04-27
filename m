From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 0/32] rt2x00
Date: Fri, 28 Apr 2006 00:02:41 +0200
Message-ID: <200604280002.46000.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3006316.gly22xNije";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.190]:44908 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751773AbWD0WBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:01:42 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388639nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:01:41 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3006316.gly22xNije
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

Here follows quite a large series of patches
for rt2x00 for the wireless-dev tree.

This will bring rt2x00 in wireless-dev up to date with
our CVS tree except that rt61pci and rt73usb are not
yet send along. They will follow within a week.

Apologies for the long delay but due to time limitations
the highest priority was put on the CVS tree and not
on the regularly sending of patches. We will do our best
to send more frequent updates, so next time other developers
of rt2x00 will also be sending the patches.

A short summary of all patches the are following:
[PATCH 1/32] rt2x00: code style fix
[PATCH 2/32] rt2x00: use enumerations
[PATCH 3/32] rt2x00: use pci_*_consistent for DMA mapping
[PATCH 4/32] rt2x00: Add eeprom_multiread function
[PATCH 5/32] rt2x00: Optimize RATE flag handling
[PATCH 6/32] rt2x00: Use arraylike accessors for entries in DMA ring
[PATCH 7/32] rt2x00: make vals static
[PATCH 8/32] rt2x00: Invalid memory allocation check
[PATCH 9/32] rt2x00: Fix antenna configuration
[PATCH 10/32] rt2x00: Move TSF counting activation to correct funtion
[PATCH 11/32] rt2x00: Add more register defines
[PATCH 12/32] rt2x00: Add USB ID's
[PATCH 13/32] rt2x00: Tune link depending on link quality
[PATCH 14/32] rt2x00: Allocate eeprom memory
[PATCH 15/32] rt2x00: Move rx_params to correct location
[PATCH 16/32] rt2x00: Make sure TX rings are empty when scanning
[PATCH 17/32] rt2x00: Put net_device structure in data_ring
[PATCH 18/32] rt2x00: Make sure device has reached requested state while suspend/resume
[PATCH 19/32] rt2x00: Fix panics in interrupt handlers
[PATCH 20/32] rt2x00: byte ordering correctness
[PATCH 21/32] rt2x00: PRIO ring should be treated as regular TX ring
[PATCH 22/32] rt2x00: Allocate ring structures in single array
[PATCH 23/32] rt2x00: Make correct cast in USB interrupt
[PATCH 24/32] rt2x00: Use correct desc_addr and data_addr
[PATCH 25/32] rt2x00: Add flag handlers
[PATCH 26/32] rt2x00: Move all USB and PCI common data into seperate headers
[PATCH 27/32] rt2x00: Put Hardware button in generic header
[PATCH 28/32] rt2x00: Support TXRX led handling
[PATCH 29/32] rt2x00: dscape compatibilitiy
[PATCH 30/32] rt2x00: Correctly initialize TX power in registers
[PATCH 31/32] rt2x00: Correctly initialization and uninitialization of device
[PATCH 32/32] rt2x00: misc fixes

Some of the patches are quite big and placed on an external server,
the link for that patch will be placed in that particular mail.
All other patches are inlined but are also available on the same server:
http://mendiosus.nl/rt2x00/rt2x00-01-code-style.diff
http://mendiosus.nl/rt2x00/rt2x00-02-enum.diff
http://mendiosus.nl/rt2x00/rt2x00-03-dma-mapping.diff
http://mendiosus.nl/rt2x00/rt2x00-04-eeprom-multiread.diff
http://mendiosus.nl/rt2x00/rt2x00-05-txrate.diff
http://mendiosus.nl/rt2x00/rt2x00-06-array.diff
http://mendiosus.nl/rt2x00/rt2x00-07-static.diff
http://mendiosus.nl/rt2x00/rt2x00-08-rate-check.diff
http://mendiosus.nl/rt2x00/rt2x00-09-antenna.diff
http://mendiosus.nl/rt2x00/rt2x00-10-tsf-counting.diff
http://mendiosus.nl/rt2x00/rt2x00-11-register.diff
http://mendiosus.nl/rt2x00/rt2x00-12-usb-ids.diff
http://mendiosus.nl/rt2x00/rt2x00-13-link-tuner.diff
http://mendiosus.nl/rt2x00/rt2x00-14-eeprom.diff
http://mendiosus.nl/rt2x00/rt2x00-15-txrx-params.diff
http://mendiosus.nl/rt2x00/rt2x00-16-scan-params.diff
http://mendiosus.nl/rt2x00/rt2x00-17-ringdev.diff
http://mendiosus.nl/rt2x00/rt2x00-18-suspend.diff
http://mendiosus.nl/rt2x00/rt2x00-19-ring.diff
http://mendiosus.nl/rt2x00/rt2x00-20-endian.diff
http://mendiosus.nl/rt2x00/rt2x00-21-prio.diff
http://mendiosus.nl/rt2x00/rt2x00-22-rings.diff
http://mendiosus.nl/rt2x00/rt2x00-23-usbhandler.diff
http://mendiosus.nl/rt2x00/rt2x00-24-usbfixes.diff
http://mendiosus.nl/rt2x00/rt2x00-25-flags.diff
http://mendiosus.nl/rt2x00/rt2x00-26-dev.diff
http://mendiosus.nl/rt2x00/rt2x00-27-button.diff
http://mendiosus.nl/rt2x00/rt2x00-28-led.diff
http://mendiosus.nl/rt2x00/rt2x00-29-compat.diff
http://mendiosus.nl/rt2x00/rt2x00-30-config.diff
http://mendiosus.nl/rt2x00/rt2x00-31-init.diff
http://mendiosus.nl/rt2x00/rt2x00-32-misc.diff

IvD

--nextPart3006316.gly22xNije
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+FaqndE37Em0gRAnCWAKCai36LcYDtPT+hxyZJUPEUTn/kGgCdH9z1
aHFqD5LTGsEezjY6tEIqnDs=
=tI3v
-----END PGP SIGNATURE-----

--nextPart3006316.gly22xNije--
