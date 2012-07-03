From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Deleting an alias causes rest to get deleted
Date: Tue, 3 Jul 2012 02:12:17 +0100
Message-ID: <1341277937.2590.25.camel@bwh-desktop.uk.solarflarecom.com>
References: <4FF1FC74.8080401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Volkan =?UTF-8?Q?Yaz=C4=B1c=C4=B1?= <volkan.yazici@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:27330 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932793Ab2GCBMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 21:12:20 -0400
In-Reply-To: <4FF1FC74.8080401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-02 at 22:54 +0300, Volkan Yaz=C4=B1c=C4=B1 wrote:
> Hi!
>=20
> I observe an IP aliasing anomaly that occurs when I try to delete an =
IP=20
> alias from an interface. That is, when I delete the first address in =
a=20
> set of IP aliased addresses assigned according to a particular subnet=
,=20
> rest of the aliases get deleted as well. Check out the below snippet.
[...]
> As a side note, when I first asked this question to Stephen Hemminger=
=20
> (he forwarded me to this mailing list) he also told me that "/In Linu=
x=20
> the interface aliases are really a legacy from the BSD style addressi=
ng,=20
> and don't act the same. It is not common practice to use them./" Is t=
hat=20
> really the case?
[...]

If you didn't give him the full details shown above, it's possible he
thought you meant alias interfaces such as 'eth0:0'.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
