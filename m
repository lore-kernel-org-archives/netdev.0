From: Rob Landley <rob@landley.net>
Subject: Re: [PATCH] Add somaxconn to Documentation/sysctl/net.txt
Date: Tue, 13 Apr 2010 18:54:13 -0500
Message-ID: <201004131854.14082.rob@landley.net>
References: <201004131325.29104.rob@landley.net> <1271184012.16881.549.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1271184012.16881.549.camel@edumazet-laptop>
Content-Disposition: inline
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 13 April 2010 13:40:12 Eric Dumazet wrote:
> Le mardi 13 avril 2010 =C3=A0 13:25 -0500, Rob Landley a =C3=A9crit :
> > From: Rob Landley <rob@landley.net>
> >
> > Add somaxconn to Documentation/sysctl/net.txt
> >
> > Signed-off-by: Rob Landley <rob@landley.net>
> > ---
> >
> >  Documentation/sysctl/net.txt |    6 ++++++
> >  1 file changed, 6 insertions(+)
> >
> > diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/ne=
t.txt
> > index df38ef0..2740085 100644
> > --- a/Documentation/sysctl/net.txt
> > +++ b/Documentation/sysctl/net.txt
> > @@ -90,6 +90,12 @@ optmem_max
> >  Maximum ancillary buffer size allowed per socket. Ancillary data i=
s a
> > sequence of struct cmsghdr structures with appended data.
> >
> > +somaxconn
> > +---------
> > +
> > +Maximum backlog of unanswered connections for a listening socket.=20
> > Provides +an upper bound on the "backlog" parameter of the listen()
> > syscall. +
> >  2. /proc/sys/net/unix - Parameters for Unix domain sockets
> >  -------------------------------------------------------
>
> Please cc netdev for such patches
>
> Extract of Documentation/networking/ip-sysctl.txt
>
> somaxconn - INTEGER
> 	Limit of socket listen() backlog, known in userspace as SOMAXCONN.
> 	Defaults to 128.  See also tcp_max_syn_backlog for additional tuning
> 	for TCP sockets.
>
> I guess you need to change both files ?

Dunno.  I just got a question on the busybox mailing list:

  http://lists.busybox.net/pipermail/busybox/2010-April/072090.html

Looked in Documentation to see what /proc/sys/net/core/somaxconn actual=
ly=20
_did_, found it was undocumented, grepped the kernel source for somaxco=
nn,=20
found just one chunk of code actually using it, replied to the guy's qu=
estion:

  http://lists.busybox.net/pipermail/busybox/2010-April/072096.html

And then tweaked the documentation with what I'd found, and sent in a d=
oc=20
patch so I wouldn't have to do that twice.

It's quite possible I got it wrong.  Maybe it's per interface or someth=
ing?

Rob
--=20
Latency is more important than throughput. It's that simple. - Linus To=
rvalds
