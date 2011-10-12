From: Hemant-vilas RAMDASI <hemant.ramdasi@stericsson.com>
Subject: RE: about phonet pipe controller
Date: Wed, 12 Oct 2011 12:58:08 +0200
Message-ID: <81C3A93C17462B4BBD7E272753C105791EAACAEA43@EXDCVYMBSTM005.EQ1STM.local>
References: <81C3A93C17462B4BBD7E272753C105791EAACAE76F@EXDCVYMBSTM005.EQ1STM.local>
 <3025840.a3oI7lSnik@leon.remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Srinidhi KASAGAR <srinidhi.kasagar@stericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:56220 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751179Ab1JLK6S convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Oct 2011 06:58:18 -0400
In-Reply-To: <3025840.a3oI7lSnik@leon.remlab.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> -----Original Message-----
> From: R=E9mi Denis-Courmont [mailto:remi.denis-courmont@nokia.com]
> Sent: Wednesday, October 12, 2011 1:28 PM
> To: Hemant-vilas RAMDASI
> Cc: Srinidhi KASAGAR; netdev@vger.kernel.org
> Subject: Re: about phonet pipe controller
>=20
> Le Mercredi 12 Octobre 2011 09:25:01 ext Hemant-vilas RAMDASI a =E9cr=
it :
> > You have mentioned in the
> > "a015f6f: Phonet: kill the ST-Ericsson pipe controller Kconfig",
> > that "Support for manually enabling the pipe flow is removed as it
> > did not work properly, does not fit well with the socket API, and
> > I am not aware of any use at the moment.."
> >
> > On STE U8500 modem, you must first create pipe in disabled state,
> then do
> > local link configuration (does't work when pipe is enabled) & then
> enable
> > pipe.
>=20
> The Kconfig option broke support for existing hardware (Nokia N900 as=
 a
> USB
> gadget) and userspace (namely the oFono ISI driver). We cannot expect
> distributions to provide two different kernel builds for different
> flavors of ISI
> modems.
>=20
> > Because of this connect() cannot be used anymore and it needs to be
> modified
> > to reintroduce pipe-controller functionality again.
>=20
> As far as I can tell, that code NEVER worked properly. Not only the u=
se
> of a
> build-time option is inappropriate, but the code did not deal with a
> number of
> new corner cases that it introduced.
>=20
Yes, I agree that build-time option is not required..But what are those=
 corner cases?

> > Do you have any suggestions?
>=20
> I'm sorry but I don't really get where you're trying to get. The code
> had more
> bugs than I could fix by myself, especially when I don't have the
> hardware and
> the specification.
>
As far as I know, connect() API was not there initially. It was impleme=
nted as part=20
of pipe-controller after your feedback.
We would like to modify connect to create pipe in disabled mode and ena=
ble it in=20
setsockopt call.=20
Basically the problem with current implementation is that there is no w=
ay today for=20
anyone to disable/enable pipe.

Regards,
Hemant
=20
