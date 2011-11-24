From: Jun Zhao <mypopydev@gmail.com>
Subject: Re: [PATCH v2] ipv4 : igmp : optimize timer modify logic in
 igmp_mod_timer()
Date: Thu, 24 Nov 2011 09:27:39 +0800
Message-ID: <1322098059.23419.13.camel@barry.localdomain>
References: <1322066322-4782-1-git-send-email-mypopydev@gmail.com>
	 <20111123.172814.1626722266908002386.davem@davemloft.net>
	 <1322088885.5402.17.camel@barry.pixelworks.com>
	 <20111123.190428.1925341377347198202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:37351 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268Ab1KXB1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 20:27:45 -0500
Received: by ywt32 with SMTP id 32so2006045ywt.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 17:27:44 -0800 (PST)
In-Reply-To: <20111123.190428.1925341377347198202.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-23 at 19:04 -0500, David Miller wrote:
> From: Jun Zhao <mypopydev@gmail.com>
> Date: Thu, 24 Nov 2011 06:54:45 +0800
>=20
> > On Wed, 2011-11-23 at 17:28 -0500, David Miller wrote:
> >> From: Jun Zhao <mypopydev@gmail.com>
> >> Date: Thu, 24 Nov 2011 00:38:42 +0800
> >>=20
> >> > When timer is pending and expires less-than-or-equal-to new dela=
y,
> >> > we need not used del_timer()/add_timer().
> >> >=20
> >> > Signed-off-by: Jun Zhao <mypopydev@gmail.com>
> >>=20
> >> You did not answer Eric's question, why are you optimizing this
> >> less-used code path?
> >=20
> > 1). Oh, in the RFC 3376 $5.2, Page 23:
>=20
> Then your commit message is terrible.
>=20
> Your commit message, one the one hand, talks about optimizing the cod=
e.
>=20
> Your explanation here talks about RFC conformance.
>=20
> Your inconsistencies, and how you ignore important questions posed to
> you like Eric's (until I point it out to you) makes your work
> incredibly irritating to review and process.

I think Eric's means the v1 patch have a obvious bug about lock, I
didn't ignore it. =EF=BC=9A=EF=BC=88

>=20
> Your patch submissions need to be more well formed and your commit
> messages need to explain exactly what your goals are with your change
> and how those goals are being met by the patch you are proposing.
>=20
> When we read "optimize timer modify logic" how the heck are we
> supposed to know what this change is actually doing?  Why should we
> think that we actually need your change?  How am we supposed to figur=
e
> out that you are fixing an RFC conformance issue?
>=20

I got it, Tks. Maybe the terrible commit message lead to the problem,
I just try to make this function more readability.

Yes, I need to describe the goals more accurately in the commit.

> I'm sorry, this patch submission is junk.  Don't send us junk.
>=20

I got it.
