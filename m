From: "Andrew Bird (Sphere Systems)" <ajb@spheresystems.co.uk>
Subject: Re: [PATCH] USB CDC-Ether - Add ZTE WWAN matches before generic Ethernet
Date: Sat, 19 May 2012 18:42:38 +0100
Message-ID: <201205191842.38567.ajb@spheresystems.co.uk>
References: <1337435767-9544-1-git-send-email-ajb@spheresystems.co.uk> <87aa14jcyi.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: oliver@neukum.name, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?utf-8?q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from queue01.mail.zen.net.uk ([212.23.3.234]:38023 "EHLO
	queue01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755607Ab2ESRnr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 13:43:47 -0400
In-Reply-To: <87aa14jcyi.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 19 May 2012, Bj=C3=B8rn Mork wrote:
> Andrew Bird <ajb@spheresystems.co.uk> writes:
> > Some ZTE WWAN devices have generic CDC Ether descriptors. Add those
> > into the whitelist so that we get FLAG_WWAN on the interface
>=20
> Are you sure none of these export QMI via the CDC Ether control
> interface?  Or are they not Qualcomm devices at all?
>=20
> As usual, if you see a spurious "CDC: unexpected notification 01" log=
ged
> from cdc_ether, then there is reason to examine those closer.  If you
> don't see any such messages, then there isn't any QMI there.
>=20
>=20
> Bj=C3=B8rn

Hi Bj=C3=B8rn,
	No these are devices that use the Icera chipset. They have cdc-acm ser=
ial=20
ports and firmware has implemented AT commands for (de)activating the p=
seudo=20
Ethernet and getting IP + DNS values etc. Actually applying this patch =
will=20
provide little in terms of operation except to make the interface name =
wwan%d=20
unstead of usb%d and to flag the interface such that Network Manager do=
es not=20
try to bring it up via DHCP as soon as it appears, like it would with a=
 fixed=20
Ethernet interface.

Good tip about the 'unexpected notification 01' I'll look out for that!

Andrew
