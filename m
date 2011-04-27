From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Maximum no of bytes Ethernet can transfer at a time ??
Date: Wed, 27 Apr 2011 14:21:50 +0200
Message-ID: <1303906910.3166.50.camel@edumazet-laptop>
References: <loom.20110427T140651-957@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ajit <ajitsa_bes@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61959 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756221Ab1D0MVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 08:21:54 -0400
Received: by wwa36 with SMTP id 36so1817349wwa.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 05:21:53 -0700 (PDT)
In-Reply-To: <loom.20110427T140651-957@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 avril 2011 =C3=A0 12:11 +0000, Ajit a =C3=A9crit :
> Guys,
>=20
> I have developed a code which uses raw sockets to transfer files. My =
code skips
> all the upper layer protocols,I have designed a small protocol of my =
own.
>=20
> Now to problem is, whenever I transfer a large file it creates a prob=
lem. If
> transfer a file of suppose 100kb or more, only 97.9 Kb is received, u=
nlike in
> the case of files smaller that 97.9.
>=20
> What can be the problem ?? Does continuously sending and receiving of=
 frames
> creates a problem ??

Sure, check your syscall returns values, and search for SO_RCVBUF &
SO_SNDBUF   (man 7 socket)




