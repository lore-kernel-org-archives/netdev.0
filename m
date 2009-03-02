From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cdc_ether: add usb id for Ericsson F3507g
Date: Sun, 01 Mar 2009 20:44:36 -0800 (PST)
Message-ID: <20090301.204436.47090886.davem@davemloft.net>
References: <87ocwqsi09.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46141
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752127AbZCBEoz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Mar 2009 23:44:55 -0500
In-Reply-To: <87ocwqsi09.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Wed, 25 Feb 2009 15:33:58 +0100

> The Ericsson F3507g wireless broadband module provides a CDC Ethernet
> compliant interface, but identifies it as a "Mobile Direct Line" CDC
> subclass, thereby preventing the CDC Ethernet class driver from picki=
ng
> it up.  This patch adds the device id to cdc_ether.c as a workaround.
>=20
> Ericsson has provided a "class" driver for this device:
> http://kerneltrap.org/mailarchive/linux-net/2008/10/28/3832094
> But closer inspection of that driver reveals that it adds little more
> than duplication of code from cdc_ether.c.  See also
> http://marc.info/?l=3Dlinux-usb&m=3D123334979706403&w=3D2
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied, thanks.
