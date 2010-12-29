From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: Bypass flow control problems
Date: Wed, 29 Dec 2010 10:47:40 +0200
Message-ID: <20101229084740.GR2754@reaktio.net>
References: <1293040291.1777.36.camel@alkis> <20101227134346.GD2754@reaktio.net> <5BBF316A-A162-4683-B6CA-6662F221F500@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alkis Georgopoulos <alkisg@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.tele.fi ([192.89.123.25]:41062 "EHLO smtp.tele.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751057Ab0L2Irw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Dec 2010 03:47:52 -0500
Content-Disposition: inline
In-Reply-To: <5BBF316A-A162-4683-B6CA-6662F221F500@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 28, 2010 at 09:05:42PM -0800, Kirsher, Jeffrey T wrote:
> On Dec 27, 2010, at 8:43, Pasi K=E4rkk=E4inen <pasik@iki.fi> wrote:
>=20
> > On Wed, Dec 22, 2010 at 07:51:31PM +0200, Alkis Georgopoulos wrote:
> >> Hi,
> >>=20
> >> I'm an IT teacher/LTSP developer. In LTSP, thin clients are netboo=
ted
> >> from a server and receive a lot of X and remote disk traffic from =
it.
> >>=20
> >> Many installations have a gigabit NIC on the server, an unmanaged
> >> gigabit switch, and 100 Mbps NICs on the clients.
> >>=20
> >> With flow control on, the server is limited to sending 100 Mbps to=
 all
> >> the clients. So with 10 thin clients the server can concurrently s=
end
> >> only 10 Mbps to each one of them.
> >>=20
> >> On NICs that support it, we turn flow control off and the server c=
an
> >> properly send 100 Mbps to each client, i.e. 1 Gbps to 10 clients.
> >>=20
> >> * Is there any way to bypass that problem on NICs that do not supp=
ort
> >>   turning off flow control, like e.g. realteks?
> >>   I.e. when a client sends a pause signal to the server, instead o=
f the
> >>   server pausing, to continue sending data to another client?
> >>   Or even to limit the amound of data the server sends to each cli=
ent,
> >>   so that the clients never have to send pause signals?
> >>=20
> >=20
> > You could set up QoS rules on the server to limit the network speed=
 per client..
> >=20
> >> * I really don't understand why flow control is enabled by default=
 on
> >>   NICs and switches. In which case does it help? As far as I
> >>   understand, all it does is ruin gigabit =3D> 100 Mbps connection=
s...
> >>=20
> >> * As a side note, since rtl8169 is a very common chipset, is there=
 a
> >>   way to disable flow control for that specific NIC?
> >>=20
> >> This problem affects thousands of LTSP installations, we'd much
> >> appreciate your knowledge and feedback on it.
> >>=20
> >=20
> > Did you try disabling flow control from the switch?=20
>=20
> He stated the switch was a un-managed switch, so he would be unable t=
o disable flow control on the switch.
>=20

Oh, I missed that :) Never mind then.

-- Pasi

