From: Jeff Mahoney <jeffm@suse.com>
Subject: [BUG] Circular dependency introduced in commit 86f6cf4127
Date: Wed, 25 Jun 2014 11:44:34 -0400
Message-ID: <53AAEE62.7010602@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Daniel Mack <zonque@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43621 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932281AbaFYPok (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 11:44:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi guys -

Commit 86f6cf4127 (net: of_mdio: add of_mdiobus_link_phydev())
introduced a circular dependency between libphy and of_mdio.

depmod: ERROR: <modroot>/kernel/drivers/net/phy/libphy.ko in
dependency cycle!
depmod: ERROR: <modroot>/kernel/drivers/of/of_mdio.ko in dependency cycle!

- -Jeff

- -- 
Jeff Mahoney
SUSE Labs
-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.19 (Darwin)

iQIcBAEBAgAGBQJTqu5iAAoJEB57S2MheeWyPMwP/3tpviCx3A70xZMxdS1QA4uK
oyoTgTK+y0i6gTh4Mtkehzt6+lZAHyRso1OkUfo0oHflFDHQFbfHmN4ec1NIghpz
L3XdLaYx0U485ziFtmnbaWm24lhgOwyK33QTMZANJ0OiOSOqNY5+NG8uxH1XOrJj
eklbNo5Cya6Veqy1P4LovfrlNK1RflGcxdPOq2a7GVpJP7dP4wupoPIhIKCZD7O0
EL3Fo9bJ3+PNZT9pAaavBx6fjqqjLGOdj3QeBSkXxYvE5rueH0UNESZM+hytgQmo
dIItCY0b95aJsxf26OcjJoWJgVX81GTlrT+HBzTLD5uKqHvi0Zt/A6RduWeS3am3
2WxlXGaFshiqeRpm+0gz5OzZnWKaLLpxMmMKqrdFFSKoaPHdqcBcKbqp2yKqGXdk
sUN/qCA5S3JPpxwbKoZOAR03NIvq6b5wyK2/LKsU3HY9eMjmGh5m1vcFnWSZ21BM
lz70tqdoWchZ9FqffE2tKsDdtaL/HOFrcq5kcRnoy5L/F5HJ4TPh/t33bTN4D8Zw
lpTPe4LgtcN1dLlgDFVLDwAHDYWQ+BBOPUYjCVtXhFCzknl+uhB4OYZ8lsb/Wx8u
apBeq3M/+wGMQw5khVOW6wM7r6EklqJbs0Zbova8aUaxknbTK4weJXAnW6BCWzHZ
6AX74FFiHH+pt/xFK8fQ
=C7lH
-----END PGP SIGNATURE-----
