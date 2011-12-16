From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: nonlocal_bind and IPv6
Date: Fri, 16 Dec 2011 12:10:27 +0100
Message-ID: <20111216111027.GA2315@electric-eye.fr.zoreil.com>
References: <1323879648-419-1-git-send-email-bernat@luffy.cx> <CAHo-OoxrYpFMBVfriB7HhL-BpMXJgCe1-mL4L8UpsDQJifMZvQ@mail.gmail.com> <m3zket9gqj.fsf@neo.luffy.cx> <20111216.020600.1695776769736304587.davem@davemloft.net> <e21a2d9682b5d83fefe3f09a07316033@luffy.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, zenczykowski@gmail.com,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Vincent Bernat <bernat@luffy.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40702 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363Ab1LPLSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 06:18:10 -0500
Content-Disposition: inline
In-Reply-To: <e21a2d9682b5d83fefe3f09a07316033@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vincent Bernat <bernat@luffy.cx> :
> On Fri, 16 Dec 2011 02:06:00 -0500 (EST), David Miller wrote:
> >>04:58, Maciej =C5=BBenczykowski <zenczykowski@gmail.com> disait=C2=A0=
:
[...]
> >>>why not simply use the IP_TRANSPARENT or IP_FREEBIND socket
> >>>options?
> >>
> >>Because  this requires  modifying each  affected software.  This
> >>can be difficult if you don't have the source code available.
> >
> >But it means that it would work on every single kernel verion out
> >there.
[...]
> Moreover, I am just adding the IPv6 version of this setting. The
> IPv4 version already exists.

=46or IPv6 this is adding a system-scope function which will have to be
maintained and available for ages. It will compete with the existing,
per-application answer. The "fix you application / design" argument
is thus stronger than with IPv4.

--=20
Ueimor
