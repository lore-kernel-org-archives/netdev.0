From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: RFC: Network privilege separation.
Date: Mon, 12 Jan 2009 21:47:57 +0200
Message-ID: <200901122147.57731.rdenis@simphalempin.com>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <12821.1231785850@turing-police.cc.vt.edu> <20090112194333.GB23848@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis.Kletnieks@vt.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:36674 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756752AbZALTsT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 14:48:19 -0500
In-Reply-To: <20090112194333.GB23848@one.firstfloor.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 janvier 2009 21:43:33 Andi Kleen, vous avez =E9crit=A0:
> > Yes, the network access part *is* something that should be part of =
a more
> > general interface.  Having said that, we currently are lacking a wa=
y for
> > a *general user* program to say "I'm all set up, and would like to
> > disavow any other further resource access (except maybe r/o access =
as
> > "other" to file systems)".
>
> seccomp does exactly that. It's quite obscure, but available in most
> linux kernels. Basically it blocks everything except
> read/write on already open file descriptors.
>
> I always thought it would be nice if codecs (which tend
> to be full of security holes) ran in such jails by default

Yeah, and there are not going to do that because there are lots of usef=
ul=20
stuff codecs like to do that represents no security issue but is nevert=
heless=20
impossible with SECCOMP (according to the documentation).

Expanding the heap, mapping memory. Getting timestamps. Waiting on fute=
xes,=20
catching signals, polling file descriptors. Seeking, doing vectorized I=
/O.=20
Cloning.


Codecs don't like to read/write raw video through a pipe...

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
