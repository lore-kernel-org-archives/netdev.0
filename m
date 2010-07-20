From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: recv(2), MSG_TRUNK and kernels older than 2.6.22
Date: Tue, 20 Jul 2010 11:24:33 +0200
Message-ID: <1279617873.2498.13.camel@edumazet-laptop>
References: <4C455DC3.1050304@marples.name>
	 <1279616099.2498.9.camel@edumazet-laptop>  <4C45678A.4080408@marples.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Roy Marples <roy@marples.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44483 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753601Ab0GTJYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 05:24:39 -0400
Received: by wwj40 with SMTP id 40so564472wwj.1
        for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 02:24:37 -0700 (PDT)
In-Reply-To: <4C45678A.4080408@marples.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 juillet 2010 =C3=A0 10:08 +0100, Roy Marples a =C3=A9crit :
> On 20/07/2010 09:54, Eric Dumazet wrote:
> > Is it for the dhcpcd problem we talk about few week ago, disturbed =
by
> > new 64bit stats ?
>=20
> Yes
>=20
> >
> > Why do you want to have a fixed size of 256 bytes ?
> >
> > Using 8192 bytes on stack would avoid MSG_TRUNK mess.
>=20
> Yes it would, but that doesn't answer my question :)

Your question might be wrong ? :=3D)

> I would like to use a buffer big enough, but not a whole 8k in size.
> dhcpcd has quite a small runtime and I'd like to keep it that way.

8192 bytes on stack is too much for you ?

Then you should automatically resize your buffer, and not using
MSG_TRUNK at all (there is no guarantee the information you need will b=
e
part of the truncated part)



