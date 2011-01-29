From: Piotr Isajew <pki@ex.com.pl>
Subject: ipheth problem in 2.6.36 and 2.6.37
Date: Sat, 29 Jan 2011 18:42:52 +0100
Message-ID: <20110129174252.GA12309@zgred.localnet>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7AUc2qLy4jB3hD7Z"
Cc: gregkh@suse.de, netdev@vger.kernel.org
To: diego@giagio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-out.strefa.interia.pl ([217.74.66.73]:52601 "EHLO
	mx-out.strefa.interia.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023Ab1A2RvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jan 2011 12:51:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

It looks for me that there is something wrong with ipheth
driver. In 2.6.35 it worked fine. However it doesn't work after
upgrade to 2.6.36 or 2.6.37:

Driver detects the iPhone and attaches it as eth interface:

[856636.512167] usb 1-1: Product: iPhone
[856636.512172] usb 1-1: Manufacturer: Apple Inc.
[856636.512178] usb 1-1: SerialNumber: 48......
[856636.512647] usb 1-1: usb_probe_device
[856636.512658] usb 1-1: configuration #1 chosen from 4 choices
[856636.513769] usb 1-1: adding 1-1:1.0 (config #1, interface 0)
[856636.514051] drivers/usb/core/inode.c: creating file '014'
[856636.514130] hub 1-0:1.0: state 7 ports 6 chg 0000 evt 0002
[856636.645496] usb 1-1: unregistering interface 1-1:1.0
[856636.645865] usb 1-1: usb_disable_device nuking non-ep0 URBs
[856636.648389] usb 1-1: adding 1-1:4.0 (config #4, interface 0)
[856636.648715] usb 1-1: adding 1-1:4.1 (config #4, interface 1)
[856636.648956] usb 1-1: adding 1-1:4.2 (config #4, interface 2)
[856637.488748] ipheth 1-1:4.2: usb_probe_interface
[856637.488760] ipheth 1-1:4.2: usb_probe_interface - got id
[856637.513964] ipheth 1-1:4.2: Apple iPhone USB Ethernet device attached
[856637.515377] usbcore: registered new interface driver ipheth


I'm sure that device pairing goes well -- bringing eth interface
"up" activates Internet modem mode on the phone. However it's not
possible to get an IP address for the interface. It's supposed to
be assigned by DHCP, but requests time out.


--7AUc2qLy4jB3hD7Z
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk1EUZwACgkQ0vhon0gbxdhXgQCeO6q5WtMXQhMCDiCRWmthrROB
l0wAoIAnOauabdpO9hty7RNkVlLHiXfk
=9uP+
-----END PGP SIGNATURE-----

--7AUc2qLy4jB3hD7Z--
