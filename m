From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: rndis: dhcp discover stopped working
Date: Mon, 11 Apr 2011 23:54:40 +0300
Message-ID: <20110411205440.GA4227@swordfish>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="a8Wt8u1KmwUX3Y2C"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,
Seems like dhcp discover stopped working with my HTC in "USB-tethering" mode:

kernel: [   60.670379] usb 2-1.3: new high speed USB device number 4 using ehci_hcd
kernel: [   60.766779] usb 2-1.3: New USB device found, idVendor=0bb4, idProduct=0c87
kernel: [   60.766787] usb 2-1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
kernel: [   60.766792] usb 2-1.3: Product: Android Phone
kernel: [   60.766796] usb 2-1.3: Manufacturer: HTC
kernel: [   60.766800] usb 2-1.3: SerialNumber: HT082PL07557
kernel: [   60.861976] Initializing USB Mass Storage driver...
kernel: [   60.862395] scsi4 : usb-storage 2-1.3:1.0
kernel: [   60.862965] usbcore: registered new interface driver usb-storage
kernel: [   60.862972] USB Mass Storage support registered.
kernel: [   61.865117] scsi 4:0:0:0: Direct-Access     HTC      Android Phone    0100 PQ: 0 ANSI: 2
kernel: [   61.874518] sd 4:0:0:0: [sdb] Attached SCSI removable disk
kernel: [   72.129190] usb 2-1.3: USB disconnect, device number 4
kernel: [   72.454846] usb 2-1.3: new high speed USB device number 5 using ehci_hcd
kernel: [   72.551186] usb 2-1.3: New USB device found, idVendor=0bb4, idProduct=0ffe
kernel: [   72.551195] usb 2-1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
kernel: [   72.551200] usb 2-1.3: Product: Android Phone
kernel: [   72.551205] usb 2-1.3: Manufacturer: HTC
kernel: [   72.551242] usb 2-1.3: SerialNumber: HT082PL07557
kernel: [   72.572416] rndis_host 2-1.3:1.0: usb0: register 'rndis_host' at usb-0000:00:1d.0-1.3, RNDIS device, e6:99:59:e3:8c:98
kernel: [   87.281911] NET: Registered protocol family 10
kernel: [   87.284969] ADDRCONF(NETDEV_UP): eth0: link is not ready
dhclient: can't create /var/db/dhclient.leases: No such file or directory
dhclient: DHCPDISCOVER on usb0 to 255.255.255.255 port 67 interval 8
kernel: [   98.003895] usb0: no IPv6 routers present
dhclient: DHCPDISCOVER on usb0 to 255.255.255.255 port 67 interval 8
dhclient: DHCPDISCOVER on usb0 to 255.255.255.255 port 67 interval 11
dhclient: DHCPDISCOVER on usb0 to 255.255.255.255 port 67 interval 15
dhclient: DHCPDISCOVER on usb0 to 255.255.255.255 port 67 interval 19
dhclient: No DHCPOFFERS received.
dhclient: No working leases in persistent database - sleeping.


kernel: .39-rc2-*


	Sergey

--a8Wt8u1KmwUX3Y2C
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iJwEAQECAAYFAk2japAACgkQfKHnntdSXjS/wgQAuzgVSIqmrlVuLQzvOsETq6DQ
URgq5tdj3oj4Br6/b9CokD1KXBflEq9dBGO/7BbPHGRUj7EnTHcsP9/GgS8IXSUi
Ws2m9VzbzeqUhjcsDuaVGT+KmPBjf+t/A6x8P0q6RWmYxdAmfybQdsTwiCelhnLv
rTHeunf2aJZComfMkIQ=
=Hp6g
-----END PGP SIGNATURE-----

--a8Wt8u1KmwUX3Y2C--
