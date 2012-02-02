From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH V4 02/13] netback: add module unload function.
Date: Thu, 02 Feb 2012 21:34:26 +0100
Message-ID: <1328214866.2480.18.camel@edumazet-laptop>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	 <1328201363-13915-3-git-send-email-wei.liu2@citrix.com>
	 <1328202524.11534.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328203710.5553.94.camel@leeds.uk.xensource.com>
	 <1328204936.13262.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328212761.28964.77.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:34666 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755758Ab2BBUeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 15:34:31 -0500
Received: by werb13 with SMTP id b13so2173819wer.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 12:34:30 -0800 (PST)
In-Reply-To: <1328212761.28964.77.camel@dagon.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 19:59 +0000, Ian Campbell a =C3=A9=
crit :
> On Thu, 2012-02-02 at 17:48 +0000, Eric Dumazet wrote:
> > Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 17:28 +0000, Wei Liu a =C3=A9c=
rit :
> >=20
> > > You're right about this.
> > >=20
> > > But this part is destined to get wiped out (in the very near futu=
re?) --
> > > see following patches. So I don't think it is worthy to fix this.
> > >=20
> >=20
> > Before adding new bugs, you must fix previous ones.
>=20
> I've never heard of this requirement before! It's a wonder anyone eve=
r
> gets anything done.
>=20
> Anyway, I think it would be reasonable to just remove the kthread_bin=
d
> call from this loop. We don't actually want/need a thread per online =
CPU
> in any strict sense, we just want there to be some number of worker
> threads available and ~numcpus at start of day is a good enough
> approximation for that number. There have been patches floating aroun=
d
> in the past which make the number of groups a module parameter which
> would also be a reasonable thing to dig out if we weren't just about =
to
> remove all this code anyway.
>=20
> So removing the kthread_bind is good enough for the short term, and f=
or
> stable if people feel that is necessary, and we can continue in mainl=
ine
> with the direction Wei's patches are taking us.
>=20

That sounds a right fix.

Why do think its not reasonable that I ask a bug fix ?

Next time, dont bother send patches for review if you dont want
reviewers.
