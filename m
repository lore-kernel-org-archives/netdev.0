From: =?big5?B?U3RlbiBXYW5nICik/aVAqfcp?= <Sten.Wang@rdc.com.tw>
Subject: RE: drivers/net/r6040.c warnings on x86_64
Date: Wed, 28 Nov 2007 16:38:52 +0800
Message-ID: <07905E0D268758488D76D7D747F21BB602079E37@rdc8.rdc>
Mime-Version: 1.0
Content-Type: text/plain; charset=big5
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?big5?B?VGltIENoZW4gKLOvpOXZeSk=?= <Tim.Chen@rdc.com.tw>
To: "Andrew Morton" <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 219-87-157-151.static.tfn.net.tw ([219.87.157.151]:53768 "EHLO
	rdc1.rdc" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752558AbXK1I46 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 03:56:58 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Andrew:

Thanks very much for your test.
Yes, you can fix it.
If you have any problem that we can help, please feel free to mail me o=
r Tim.
Thnaks.

Best Regards,

Sten

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D

                      E-mail Confidentiality Notice =20

The information in this e-mail is confidential and may be legally privi=
leged otherwise protected from disclosure .It is intended solely for th=
e addressee .Access to this e-mail by anyone else is unauthorized .If y=
ou are not the intended recipient, any disclosure, copying, distributio=
n or any action taken or omitted to be taken in reliance on it, is proh=
ibited and maybe unlawful.Please delete the message and any attachments=
 from your computer system; and destroy all hard copies.=20

ALL Intellectual Property Rights of RDC Reserved.


-----Original Message-----
=46rom: Andrew Morton [mailto:akpm@linux-foundation.org]=20
Sent: Wednesday, November 28, 2007 3:06 PM
To: Sten Wang (=A4=FD=A5@=A9=F7); netdev@vger.kernel.org
Subject: Re: drivers/net/r6040.c warnings on x86_64

On Tue, 27 Nov 2007 20:45:36 -0800 Andrew Morton <akpm@google.com> wrot=
e:

> drivers/net/r6040.c: In function 'rx_buf_alloc':
> drivers/net/r6040.c:262: warning: passing argument 2 of 'pci_map_sing=
le' makes pointer from integer without a cast
> drivers/net/r6040.c: In function 'r6040_up':
> drivers/net/r6040.c:631: warning: cast from pointer to integer of dif=
ferent size
> drivers/net/r6040.c:632: warning: cast to pointer from integer of dif=
ferent size
> drivers/net/r6040.c:637: warning: cast from pointer to integer of dif=
ferent size
> drivers/net/r6040.c:638: warning: cast to pointer from integer of dif=
ferent size
>=20
> can we fix these please?

it breaks the sparc64 build too

drivers/net/r6040.c: In function `rx_buf_alloc':
drivers/net/r6040.c:262: warning: passing arg 2 of `pci_map_single' mak=
es pointer from integer without a cast
drivers/net/r6040.c:262: warning: passing arg 2 of `pci_map_single' mak=
es pointer from integer without a cast
drivers/net/r6040.c:262: warning: passing arg 2 of `pci_map_single' mak=
es pointer from integer without a cast
drivers/net/r6040.c:262: warning: passing arg 2 of `pci_map_single' mak=
es pointer from integer without a cast
drivers/net/r6040.c:262: warning: passing arg 2 of `pci_map_single' mak=
es pointer from integer without a cast
drivers/net/r6040.c:262: warning: passing arg 2 of `pci_map_single' mak=
es pointer from integer without a cast
drivers/net/r6040.c: In function `r6040_up':
drivers/net/r6040.c:631: warning: cast from pointer to integer of diffe=
rent size
drivers/net/r6040.c:631: warning: cast from pointer to integer of diffe=
rent size
drivers/net/r6040.c:631: warning: cast from pointer to integer of diffe=
rent size
drivers/net/r6040.c:631: warning: cast from pointer to integer of diffe=
rent size
drivers/net/r6040.c:631: warning: cast from pointer to integer of diffe=
rent size
drivers/net/r6040.c:631: warning: cast from pointer to integer of diffe=
rent size
drivers/net/r6040.c:632: error: implicit declaration of function `virt_=
to_bus'
drivers/net/r6040.c:632: warning: cast to pointer from integer of diffe=
rent size
drivers/net/r6040.c:637: warning: cast from pointer to integer of diffe=
rent size
drivers/net/r6040.c:637: warning: cast from pointer to integer of diffe=
rent size
drivers/net/r6040.c:637: warning: cast from pointer to integer of diffe=
rent size
drivers/net/r6040.c:637: warning: cast from pointer to integer of diffe=
rent size
drivers/net/r6040.c:637: warning: cast from pointer to integer of diffe=
rent size
drivers/net/r6040.c:637: warning: cast from pointer to integer of diffe=
rent size
drivers/net/r6040.c:638: warning: cast to pointer from integer of diffe=
rent size
