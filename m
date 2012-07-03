From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Deleting an alias causes rest to get deleted
Date: Mon, 2 Jul 2012 19:44:29 -0700
Message-ID: <20120702194429.7c865c94@nehalam.linuxnetplumber.net>
References: <4FF1FC74.8080401@gmail.com>
	<1341277937.2590.25.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Volkan =?UTF-8?B?WWF6xLFjxLE=?= <volkan.yazici@gmail.com>,
	<netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50502 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753460Ab2GCCon convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 22:44:43 -0400
In-Reply-To: <1341277937.2590.25.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Jul 2012 02:12:17 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Mon, 2012-07-02 at 22:54 +0300, Volkan Yaz=C4=B1c=C4=B1 wrote:
> > Hi!
> >=20
> > I observe an IP aliasing anomaly that occurs when I try to delete a=
n IP=20
> > alias from an interface. That is, when I delete the first address i=
n a=20
> > set of IP aliased addresses assigned according to a particular subn=
et,=20
> > rest of the aliases get deleted as well. Check out the below snippe=
t.
> [...]
> > As a side note, when I first asked this question to Stephen Hemming=
er=20
> > (he forwarded me to this mailing list) he also told me that "/In Li=
nux=20
> > the interface aliases are really a legacy from the BSD style addres=
sing,=20
> > and don't act the same. It is not common practice to use them./" Is=
 that=20
> > really the case?
> [...]
>=20
> If you didn't give him the full details shown above, it's possible he
> thought you meant alias interfaces such as 'eth0:0'.

Yes, that is what I was assuming by the word 'alias'
