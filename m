From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 3/3] TCPCT part 1c: initial SYN exchange
 with SYNACK data
Date: Wed, 28 Oct 2009 13:14:01 -0400
Message-ID: <4AE87BD9.3040703@gmail.com>
References: <4AE6E35C.2050101@gmail.com> <4AE6E7C0.2050408@gmail.com> <4AE8527E.4080603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:38563 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753058AbZJ1ROE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 13:14:04 -0400
Received: by bwz19 with SMTP id 19so1214954bwz.28
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2009 10:14:08 -0700 (PDT)
In-Reply-To: <4AE8527E.4080603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> William Allen Simpson a =E9crit :
>> suggested for many years, and is also useful without SYN data, allow=
ing
>> several related concepts to use the same extension option.
>>
>>    "Re: SYN floods (was: does history repeat itself?)", September 9,=
 1996.
>>    http://www.merit.net/mail.archives/nanog/1996-09/msg00235.html
>=20
> Sorry this link might be interesting to you, but I found nothing that=
 explains
> your patches.
>=20
>>    "Re: what a new TCP header might look like", May 12, 1998.
>>    ftp://ftp.isi.edu/end2end/end2end-interest-1998.mail
>=20
> Same here....
>=20
They explain the "several related concepts" -- indeed the entire scope =
of
the whole project.  That's why this patch series is labeled "part 1".


> I tried to find an RFC or document about this stuff and failed.
>=20
This patch series was fairly clearly described in Adam's draft last yea=
r.
It's expired now, but I'll send you a copy privately.


> Before reading implementation code, I like to have english text that =
describes
> the new concept/design.
>=20
Before writing text, I like to have implementation code.... :-)

In fact, it has long been my position that we shouldn't publish IETF RF=
Cs
without running code (and I never have).  Even PPP over SOnet/SDH had
preliminary hardware before publication.  Unfortunately, those with
standards-bodies-itis have a sad history of the opposite.

The Usenix ;login: overview and other documents are embargoed until
(December) publication, but I'll send you some recent galleys privately=
=2E


> (BTW I found http://ttcplinux.sourceforge.net/theses/ETTCP.pdf and fo=
und it interesting,
> I wonder what happened to this)
>=20
I found it too, and deliberately extended Adam's sockopt to encompass i=
t.
It's one reason this was renamed TCP Cookie *Transactions* (TCPCT).  Th=
at
will come along later, probably about parts 4 or 5.
