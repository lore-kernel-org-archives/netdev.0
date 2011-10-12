From: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Subject: Re: about phonet pipe controller
Date: Wed, 12 Oct 2011 10:58:05 +0300
Message-ID: <3025840.a3oI7lSnik@leon.remlab.net>
References: <81C3A93C17462B4BBD7E272753C105791EAACAE76F@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Srinidhi KASAGAR <srinidhi.kasagar@stericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: ext Hemant-vilas RAMDASI <hemant.ramdasi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.47]:34780 "EHLO mgw-sa01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751743Ab1JLH6H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 03:58:07 -0400
In-Reply-To: <81C3A93C17462B4BBD7E272753C105791EAACAE76F@EXDCVYMBSTM005.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Mercredi 12 Octobre 2011 09:25:01 ext Hemant-vilas RAMDASI a =E9crit=
 :
> You have mentioned in the
> "a015f6f: Phonet: kill the ST-Ericsson pipe controller Kconfig",
> that "Support for manually enabling the pipe flow is removed as it
> did not work properly, does not fit well with the socket API, and
> I am not aware of any use at the moment.."
>=20
> On STE U8500 modem, you must first create pipe in disabled state, the=
n do
> local link configuration (does't work when pipe is enabled) & then en=
able
> pipe.

The Kconfig option broke support for existing hardware (Nokia N900 as a=
 USB=20
gadget) and userspace (namely the oFono ISI driver). We cannot expect=20
distributions to provide two different kernel builds for different flav=
ors of ISI=20
modems.

> Because of this connect() cannot be used anymore and it needs to be m=
odified
> to reintroduce pipe-controller functionality again.

As far as I can tell, that code NEVER worked properly. Not only the use=
 of a=20
build-time option is inappropriate, but the code did not deal with a nu=
mber of=20
new corner cases that it introduced.

> Do you have any suggestions?

I'm sorry but I don't really get where you're trying to get. The code h=
ad more=20
bugs than I could fix by myself, especially when I don't have the hardw=
are and=20
the specification.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
