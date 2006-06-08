From: Hans Henrik Happe <hhh@imada.sdu.dk>
Subject: Re: Netchannels: netchannel vs. socket. 2:0.
Date: Fri, 9 Jun 2006 01:00:24 +0200
Message-ID: <200606090100.24827.hhh@imada.sdu.dk>
References: <20060608171555.GA10273@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from berlioz.imada.sdu.dk ([130.225.128.12]:16123 "EHLO
	berlioz.imada.sdu.dk") by vger.kernel.org with ESMTP
	id S965048AbWFHXA1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 19:00:27 -0400
Received: from localhost (localhost [127.0.0.1])
	by localhost.imada.sdu.dk (Postfix) with ESMTP id 77A5162706
	for <netdev@vger.kernel.org>; Fri,  9 Jun 2006 01:00:26 +0200 (CEST)
Received: from berlioz.imada.sdu.dk ([127.0.0.1])
 by localhost (berlioz.imada.sdu.dk [127.0.0.1]) (amavisd-new, port 10025)
 with ESMTP id 22937-02 for <netdev@vger.kernel.org>;
 Thu,  8 Jun 2006 23:00:26 +0000 (UTC)
Received: from [192.168.2.100] (unknown [85.218.152.97])
	(using SSLv3 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by berlioz.imada.sdu.dk (Postfix) with ESMTP id 28BE962704
	for <netdev@vger.kernel.org>; Fri,  9 Jun 2006 01:00:26 +0200 (CEST)
To: netdev@vger.kernel.org
In-Reply-To: <20060608171555.GA10273@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 08 June 2006 19:15, you wrote:
> After some enhancements made for netchannel subsystem I'm pleased to
> announce, that netchannel subsystem outperforms existing layered desi=
gn
> both in CPU usage and network speed.
>=20
> Well, after such pretentious introduction I want to cool things down.
> CPU usage is about 1-2% less for netchannels and network performance =
is
> about 1-2 MB higher and sometimes exceeds 84 MB/sec which, I think,=20
> is maximum for given network setup (e1000 receive, r8169 send, 1500 M=
TU).

I have followed your work closely and have wondered how it affects late=
ncy?
I have somewhat limited knowledge about TCP and how the kernel handles =
it, but=20
I guess the path from NIC to userspace hasn't increased. What about sys=
call=20
overhead caused by userspace TCP processing?

H=B3 =20

