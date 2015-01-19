From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] phonet netlink: allow multiple messages per skb in
 route dump
Date: Mon, 19 Jan 2015 21:14:44 +0100
Message-ID: <1421698484.1965.44.camel@sipsolutions.net>
References: <1421666124-16055-1-git-send-email-johannes@sipsolutions.net>
	 <45863435.BJJN05sX3K@philogene>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Sakari Ailus <sakari.ailus@nokia.com>,
	Remi Denis-Courmont <courmisch@gmail.com>
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:36388 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396AbbASUOr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2015 15:14:47 -0500
In-Reply-To: <45863435.BJJN05sX3K@philogene>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-01-19 at 22:11 +0200, R=C3=A9mi Denis-Courmont wrote:
> Le lundi 19 janvier 2015, 12:15:24 Johannes Berg a =C3=A9crit :
> > From: Johannes Berg <johannes.berg@intel.com>
> >=20
> > My previous patch to this file changed the code to be bug-compatibl=
e
> > towards userspace. Unless userspace (which I wasn't able to find)
> > implements the dump reader by hand in a wrong way, this isn't neede=
d.
>=20
> The canonical userspace is there (specifically src/pnroute.c):
> https://gitorious.org/meego-cellular/phonet-utils/

Ah, cool.

> AFAICT, it should work either way. By now, I expect what's left of th=
e=20
> Maemo/Meego/Mer/whatever community has forked or rewritten it though.

The loop

	for (struct nlmsghdr *nlh =3D (struct nlmsghdr *)&req;
	     NLMSG_OK (nlh, (size_t)ret); nlh =3D NLMSG_NEXT (nlh, ret))

should make it do the right thing, I agree.

johannes
