From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] ipv4: add support for linkdown sysctl to
 netconf
Date: Wed, 8 Jul 2015 08:42:23 -0400
Message-ID: <20150708124222.GA32875@gospo.home.greyhouse.net>
References: <1436291817-1555-1-git-send-email-gospo@cumulusnetworks.com>
 <559CF0D6.3090602@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:36414 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932902AbbGHMmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 08:42:35 -0400
Received: by qkei195 with SMTP id i195so161583777qke.3
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 05:42:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <559CF0D6.3090602@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 08, 2015 at 11:43:50AM +0200, Nicolas Dichtel wrote:
> Le 07/07/2015 19:56, Andy Gospodarek a =E9crit :
> >This kernel patch exports the value of the new
> >ignore_routes_with_linkdown via netconf.
> >
> >v2: changes to notify userspace via netlink when sysctl values chang=
e
> >and proposed for 'net' since this could be considered a bugfix
> Hmm, commit title contains net-next, not net.
I went back and forth about where it should land.

Dave, any chance we might be able to add this to 'net' rather than
saving it for 4.3?  It isn't a bug-fix per se, but does help make this
feature complete.

>=20
> >
> >Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> >Suggested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>=20
> >---
> >I realize two of these changes result in lines >80 chars, but this i=
s to
> >keep the coding-style used by the surrounding code.
> >
> >There are multiple ways to resolve this, but one would be to shorten=
 the
> >defines used for this feature as "IGNORE_ROUTES_WITH_LINKDOWN" is a
> >mouthful.  I would propose dropping "_WITH_" from all the defines an=
d
> >have only "IGNORE_ROUTES_LINKDOWN" everywhere.  Doing this now in 'n=
et'
> Yes. Or even shorter: IGNORE_NH_LINKDOWN?
That might be a more appropriate name considering multipath/ecmp cases.

>=20
> >would be ideal before a release happens and it cannot be changed.
> Yes.
I'll cook up an update based on this patch and see what it looks like.
