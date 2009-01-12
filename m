From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: RFC: Network privilege separation.
Date: Mon, 12 Jan 2009 22:30:25 +0200
Message-ID: <200901122230.25976.rdenis@simphalempin.com>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <200901122215.27842.rdenis@simphalempin.com> <20090112203931.GD23848@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis.Kletnieks@vt.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:37694 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757411AbZALUa3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 15:30:29 -0500
In-Reply-To: <20090112203931.GD23848@one.firstfloor.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 janvier 2009 22:39:31 Andi Kleen, vous avez =E9crit=A0:
> > What's the point of writing a parser (that could also have bugs) wh=
en the
>
> Sorry you lost me. What do you mean with parser here?
>
> > kernel can do it?
>
> And what does it have to do with the kernel?

The parser at the other end of the pipe. The more intricate the over-th=
e-pipe=20
protocol is, the more likely it is to be buggy and the security scheme =
to=20
break.

> > A normal DVD would be over 30 megabytes per seconds once decoded, j=
ust
> > for the
>
> On many modern systems 30MB/s copies is nothing ... Also in this
> case they tend to be cache hot, which makes them much cheaper.

> Yes it would be somewhat slower, but if it avoids a couple of securit=
y
> updates that would be probably worth it.

If codecs did not care about performance, they'd be written in some hig=
h-level=20
language that could easily be sandboxed by its own VM.

As the guy who's been dealing with VLC security issues for the past two=
 years,=20
I have to say, I am in no way interested in SECCOMP as it _currently_ i=
s.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
