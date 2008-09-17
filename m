From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 00/14] [RFC] Phonet protocol stack
Date: Wed, 17 Sep 2008 16:52:26 +0300
Message-ID: <200809171652.27066.remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221595744.4989.4.camel@californication>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext Marcel Holtmann" <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:64548 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbYIQNwq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 09:52:46 -0400
In-Reply-To: <1221595744.4989.4.camel@californication>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tuesday 16 September 2008 23:09:04 ext Marcel Holtmann, you wrote:
> > This patchset provides a simple datagram socket
> > independent of the underlying hardware (network interface) through
> > which the modem is attached. We are in the process of contributing
> > a lower-layer driver through Linux OMAP.
>
> We are using PhoNet over Bluetooth and IrDA inside the Gnokii project
> and if we have a common PhoNet stack inside the Linux kernel that is
> supported by Nokia, I do wanna use that. What are your plans for this=
?

Our current plan is to add GPRS data support to the Maemo Software plat=
form.=20
As the Nokia modems talk PhoNet, we plan to use this PhoNet stack to co=
ntrol=20
GPRS functionality and to carry IP datagrams. Underneath the PhoNet sta=
ck, a=20
Linux network device driver would be required. In our case, Carlos Chin=
ea is=20
publishing the OMAP SSI bus, on linux-omap.

If I understand correctly, you want to use PhoNet with S40 and/or Symbi=
an/S60=20
phones. The architecture of the PhoNet stack allows this - running on a=
 Linux=20
PC. Additional network device drivers would be needed to support the Ir=
DA and=20
Bluetooth link-layers. We are investigating the possibility to contribu=
te=20
other drivers in the future, but we have no immediate plans to do so.

Best regards,

--=20
R=C3=A9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
