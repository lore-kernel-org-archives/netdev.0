From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH V4 02/13] netback: add module unload function.
Date: Fri, 03 Feb 2012 08:25:10 +0100
Message-ID: <1328253910.2480.41.camel@edumazet-laptop>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	 <1328201363-13915-3-git-send-email-wei.liu2@citrix.com>
	 <1328202524.11534.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328203710.5553.94.camel@leeds.uk.xensource.com>
	 <1328204936.13262.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328212761.28964.77.camel@dagon.hellion.org.uk>
	 <1328214866.2480.18.camel@edumazet-laptop>
	 <1328215821.13189.24.camel@dagon.hellion.org.uk>
	 <CAP=VYLq3CZBjC2ecOdGqAejN5Atu9kd1HovhQwc-eVk-q8ArJA@mail.gmail.com>
	 <1328251092.13189.29.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43500 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270Ab2BCHZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 02:25:15 -0500
Received: by werb13 with SMTP id b13so2450778wer.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 23:25:13 -0800 (PST)
In-Reply-To: <1328251092.13189.29.camel@dagon.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 f=C3=A9vrier 2012 =C3=A0 06:38 +0000, Ian Campbell a =C3=
=A9crit :
> On Thu, 2012-02-02 at 22:52 +0000, Paul Gortmaker wrote:
> > On Thu, Feb 2, 2012 at 3:50 PM, Ian Campbell <Ian.Campbell@citrix.c=
om> wrote:
> > > On Thu, 2012-02-02 at 20:34 +0000, Eric Dumazet wrote:
> >=20
> > [...]
> >=20
> > >
> > > I don't think it is at all unreasonable to ask for bug fixes but =
in this
> > > case Wei's series is removing the code in question (which would a=
lso
> > > undoubtedly fix the bug).
> > >
> > > As it happens the fix turns out to be simple but if it were compl=
ex I
> > > would perhaps have disagreed more strongly about spending effort =
fixing
> > > code that is removed 2 patches later, although obviously that wou=
ld have
> > > depended on the specifics of the fix in that case.
> >=20
> > Lots of people are relying on git bisect.  If you introduce build f=
ailures
> > or known bugs into any point in history, you take away from the val=
ue
> > in git bisect.  Sure, it happens by accident, but it shouldn't ever=
 be
> > done knowingly.
>=20
> Sure. In this case the bug has been there since 2.6.39, it isn't
> introduced by this series.
>=20

We are stuck right now with a bug introduced in 2.6.39, (IP redirects),
and because fix was done in 3.1, we are unable to provide a fix fo
stable 3.0 kernel.

Something that takes 15 minutes to fix now, can take several days of
work later.
