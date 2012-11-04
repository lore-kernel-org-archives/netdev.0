From: Lee Jones <lee.jones@linaro.org>
Subject: Re: [PATCH 8/9] isdn: Remove unused variable causing a compile build
 warning
Date: Sun, 4 Nov 2012 11:53:32 +0100
Message-ID: <20121104105332.GC27124@gmail.com>
References: <1351980150-24145-1-git-send-email-lee.jones@linaro.org>
 <1351980150-24145-9-git-send-email-lee.jones@linaro.org>
 <1351982441.1434.5.camel@x61.thuisdomein>
 <20121103224832.GA24262@gmail.com>
 <1352024091.1434.17.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:41248 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250Ab2KDKxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2012 05:53:36 -0500
Received: by mail-ea0-f174.google.com with SMTP id c13so1894407eaa.19
        for <netdev@vger.kernel.org>; Sun, 04 Nov 2012 02:53:34 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1352024091.1434.17.camel@x61.thuisdomein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 04 Nov 2012, Paul Bolle wrote:

> On Sat, 2012-11-03 at 23:48 +0100, Lee Jones wrote:
> > On Sat, 03 Nov 2012, Paul Bolle wrote:
> > > On Sat, 2012-11-03 at 23:02 +0100, Lee Jones wrote:
> > > > This patch fixes:
> > > > drivers/isdn/i4l/isdn_common.c: In function =E2=80=98isdn_ioctl=
=E2=80=99:
> > > > drivers/isdn/i4l/isdn_common.c:1278:8: warning: unused variable=
 =E2=80=98s=E2=80=99 [-Wunused-variable]
> > >=20
> > > Did you have CONFIG_NETDEVICES not set in this build?
> >=20
> > Ah yes, I see it. The function went down further than I thought
> > it did. So the real fix is to ensure 's' is defined inside of
> > some ifdef CONFIG_NETDEVICES guards.=20
>=20
> What puzzles me is that we only find these "#ifdef CONFIG_NETDEVICES"
> guards in this file and not in isdn_net.c, were all the ioctl command=
s
> guarded that way seem to be calling into. On first glance that doesn'=
t
> make much sense.
>=20
> (Actually the idea of having ISDN without NETDEVICES is a bit puzzlin=
g
> too. But there are too many parts of the isdn subsystem that I'm
> unfamiliar with to say whether that can make sense.)

I'm in the same position as you Paul. I just noticed the warning so
fixed it following the current way of doing things. Any, more
substantial changes requiring greater knowledge of the subsystem
would have to be done by someone else.

--=20
Lee Jones
Linaro ST-Ericsson Landing Team Lead
Linaro.org =E2=94=82 Open source software for ARM SoCs
=46ollow Linaro: Facebook | Twitter | Blog
