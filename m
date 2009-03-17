From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Tue, 17 Mar 2009 10:03:50 +0100
Message-ID: <87tz5s1pxl.fsf@nemi.mork.no>
References: <20090316233934.GD32111@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:49039 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753667AbZCQJEK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 05:04:10 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1LjVDU-0008S2-3A
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 09:04:08 +0000
Received: from 193.160.199.2 ([193.160.199.2])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2009 09:04:08 +0000
Received: from bjorn by 193.160.199.2 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2009 09:04:08 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46elix von Leitner <felix-kernel@fefe.de> writes:

> bind(3, {sa_family=3DAF_INET6, sin6_port=3Dhtons(6969), inet_pton(AF_=
INET6, "::ffff:0.0.0.0", &sin6_addr), sin6_flowinfo=3D0, sin6_scope_id=3D=
0}, 28) =3D -1 EADDRNOTAVAIL (Cannot assign requested address)
>
> This is supposed to work, and it works on other operating systems, ev=
en
> on Mac OS X.
>
> I think it used to work on Linux, too.

You can find testresults for a number of (older) OSes here:
http://www.kame.net/newsletter/20010504/

You'll probably have to refer to the bindtest man page to interprete th=
e
results:  http://www.jinmei.org/bindtest-man.txt



Bj=C3=B8rn

