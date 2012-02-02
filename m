From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [RFC PATCH V4 02/13] netback: add module unload function.
Date: Thu, 2 Feb 2012 20:50:21 +0000
Message-ID: <1328215821.13189.24.camel@dagon.hellion.org.uk>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	 <1328201363-13915-3-git-send-email-wei.liu2@citrix.com>
	 <1328202524.11534.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328203710.5553.94.camel@leeds.uk.xensource.com>
	 <1328204936.13262.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328212761.28964.77.camel@dagon.hellion.org.uk>
	 <1328214866.2480.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:47672 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757166Ab2BBUuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 15:50:23 -0500
In-Reply-To: <1328214866.2480.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-02 at 20:34 +0000, Eric Dumazet wrote:
> Le jeudi 02 f=E9vrier 2012 =E0 19:59 +0000, Ian Campbell a =E9crit :
> > On Thu, 2012-02-02 at 17:48 +0000, Eric Dumazet wrote:
> > > Le jeudi 02 f=E9vrier 2012 =E0 17:28 +0000, Wei Liu a =E9crit :
> > >=20
> > > > You're right about this.
> > > >=20
> > > > But this part is destined to get wiped out (in the very near fu=
ture?) --
> > > > see following patches. So I don't think it is worthy to fix thi=
s.
> > > >=20
> > >=20
> > > Before adding new bugs, you must fix previous ones.
> >=20
> > I've never heard of this requirement before! It's a wonder anyone e=
ver
> > gets anything done.
> >=20
> > Anyway, I think it would be reasonable to just remove the kthread_b=
ind
> > call from this loop. We don't actually want/need a thread per onlin=
e CPU
> > in any strict sense, we just want there to be some number of worker
> > threads available and ~numcpus at start of day is a good enough
> > approximation for that number. There have been patches floating aro=
und
> > in the past which make the number of groups a module parameter whic=
h
> > would also be a reasonable thing to dig out if we weren't just abou=
t to
> > remove all this code anyway.
> >=20
> > So removing the kthread_bind is good enough for the short term, and=
 for
> > stable if people feel that is necessary, and we can continue in mai=
nline
> > with the direction Wei's patches are taking us.
> >=20
>=20
> That sounds a right fix.
>
> Why do think its not reasonable that I ask a bug fix ?

I don't think it is at all unreasonable to ask for bug fixes but in thi=
s
case Wei's series is removing the code in question (which would also
undoubtedly fix the bug).

As it happens the fix turns out to be simple but if it were complex I
would perhaps have disagreed more strongly about spending effort fixing
code that is removed 2 patches later, although obviously that would hav=
e
depended on the specifics of the fix in that case.

> Next time, dont bother send patches for review if you dont want
> reviewers.

The review which you are doing is certainly very much appreciated, I'm
sorry if my disagreement over this one point gave/gives the impression
that it is not.

Ian.
