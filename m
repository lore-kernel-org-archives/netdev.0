From: Paul Moore <paul@paul-moore.com>
Subject: Re: NULL pointer deref, selinux_socket_unix_may_send+0x34/0x90
Date: Fri, 22 Mar 2013 12:24:38 -0400
Message-ID: <3405435.XFBqjMtCVW@sifl>
References: <CAMpz-8YY1ZFJnx5JAuGu3GBYhkbnYggEAqmVMQoHg7eqKNtyeg@mail.gmail.com> <2355680.noQDWa4NlY@sifl> <CAMpz-8bzjyBzk+mkaR-hHndtRZVyTb0LX8idEvypRV-itdSRYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eparis@redhat.com, sds@tycho.nsa.gov
To: =?utf-8?B?SsOhbiBTdGFuxI1law==?= <jan.stancek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f178.google.com ([209.85.128.178]:45444 "EHLO
	mail-ve0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933715Ab3CVQYl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 12:24:41 -0400
Received: by mail-ve0-f178.google.com with SMTP id db10so3408511veb.23
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 09:24:41 -0700 (PDT)
In-Reply-To: <CAMpz-8bzjyBzk+mkaR-hHndtRZVyTb0LX8idEvypRV-itdSRYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, March 22, 2013 04:48:32 PM J=C3=A1n Stan=C4=8Dek wrote:
> Hi Paul,
>=20
> thanks for reply, I'll try your patch and let you know.

Great, thanks.
=20
> I'm not certain about cause either, but patch I sent in last email
> makes it go away, so maybe that can help in some way.

At the very least you've found a way to reproduce the problem and your =
patch=20
furthers my belief that we've got a race condition somewhere - all very=
=20
helpful!  It may also turn out that your patch is the "right" solution,=
 I'd=20
just like to better understand why we are seeing the race in the first =
place.

> I made a v2 of the reproducer (attached), which triggers the issue a =
lot
> faster on 2 systems I tried (32 CPU and 4 CPU systems) - just in coup=
le of
> seconds.

Excellent, while I don't have a 32 cpu system handy, I do have a 4 cpu =
system=20
that I can play with.  Thanks again.

-Paul

--=20
paul moore
www.paul-moore.com
