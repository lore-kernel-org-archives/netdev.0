From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] iproute:  Support cross-compiling.
Date: Wed, 16 Nov 2011 05:44:30 +0100
Message-ID: <1321418670.32381.1.camel@edumazet-laptop>
References: <1321405482-18445-1-git-send-email-greearb@candelatech.com>
	 <20111115171722.02fa1c77@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59413 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312Ab1KPEof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 23:44:35 -0500
Received: by wwe5 with SMTP id 5so84788wwe.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 20:44:34 -0800 (PST)
In-Reply-To: <20111115171722.02fa1c77@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 novembre 2011 =C3=A0 17:17 -0800, Stephen Hemminger a =C3=A9=
crit :
> On Tue, 15 Nov 2011 17:04:42 -0800
> greearb@candelatech.com wrote:
>=20
> > From: Ben Greear <greearb@candelatech.com>
> >=20
> > This lets users use their own compiler instead of
> > hard-coding to use gcc.
> >=20
> > Also adds tests to disable some things that were not supported
> > in my ARM cross-compile toolchain.
> >=20
> > Signed-off-by: Ben Greear <greearb@candelatech.com>
>=20
> Can't you do this by setting up the compile environment better?
> I would rather have the tools work with all features and handle
> errors from kernel rather than neutering it.

I have roughly same errors when compiling on RHEL4

glibc-2.3.4-2.36 doesnt contain unshare() call, but my dev kernel
certainly have it ;)
