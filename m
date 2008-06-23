From: Didier Raboud <didier@raboud.com>
Subject: Re: stuck tcp connections 2.6.26-rc7
Date: Mon, 23 Jun 2008 19:04:56 +0200
Message-ID: <g3ol3u$li2$1@ger.gmane.org>
References: <dd18b0c30806221109t2ff73f9ai52f6716748648a79@mail.gmail.com> <20080622205927.301501e7.akpm@linux-foundation.org> <dd18b0c30806230013x5446991bi9eba7623ffaae131@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:44118 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756292AbYFWRKI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 13:10:08 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1KApYJ-0005IM-3Q
	for netdev@vger.kernel.org; Mon, 23 Jun 2008 17:10:03 +0000
Received: from 154-100.5-85.cust.bluewin.ch ([85.5.100.154])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 17:10:03 +0000
Received: from didier by 154-100.5-85.cust.bluewin.ch with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 17:10:03 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Justin Mattock wrote:

> On Mon, Jun 23, 2008 at 3:59 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Sun, 22 Jun 2008 18:09:16 +0000 "Justin Mattock"
>> <justinmattock@gmail.com> wrote:
>>
>>> Hello; I too am experiencing internet connectivity problems, for  a
>>> while I thought
>>> It was due to low bandwidth(or being ddos attacked) but yesterday I
>>> noticed with watch netstat -ntu
>>> send-Q was stuck on a number; the connection would not go to TIME_W=
AIT
>>> resulting in music to pause, and t.v. to freeze.
>>> In my experiences running xmms streaming music is fine, no problems=
,
>>> but as soon as
>>> you watch something with flash player the stream start's getting
>>> really bad. In the past with older kernel's
>>> I usually can watch t.v.(with flash) and stream music at the same t=
ime
>>> without any trouble.
>>> lately I've been Running the kernel in No forced Preemption with a
>>> time frequency at 100. having the kernel set in this mode really sh=
ows
>>> the connection problems, but if I change the preemption to another,
>>> and bump up the timer frequency the poor internet connection is not=
 as
>>> bad(or stuck tcp) but still prevalent. more pops in the music, and
>>> sudden internet loss for around five seconds, then goes back
>>> So from over here streaming music has no problems from what I can s=
ee,
>>> but as soon as I watch media, it becomes a mess.
>>
>> (cc netdev)
>>
>=20
>=20
> Cool, Thanks for sending the cc
> regards;

Hi,

I get something like a similar bug: when pinging my local gateway, I lo=
ose
packets (over wifi (iwl3945) ). Before the update to 2.6.26-rc7 (Debian=
), I
had no such issues (which makes Internet browsing working but weirdly).

I can't know for sure that my bug is related to the above, but suppose =
so.
Please ask for details=C2=A0!

Regards,=20

Didier Raboud
- --=20
Swisslinux.org =E2=88=92 Le carrefour GNU/Linux en Suisse =E2=88=92
http://www.swisslinux.org
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkhf17gACgkQwW1nnOmiePC/jQCcDxxCCFQbWV9swc0LY/o+/8o1
gL4An225WZd8UquZMtRfYRklKi9kiOEI
=3DhXPR
-----END PGP SIGNATURE-----

