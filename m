From: Philippe Biondi <biondi@cartel-securite.fr>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: Thu, 22 May 2003 01:11:35 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.40.0305220107460.29409-100000@phil.home.phil>
References: <3ECB9F6A.20004@ethanet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable
Cc: Jamal Hadi <hadi@shell.cyberus.ca>,
   Martin Josefsson <gandalf@wlug.westbo.se>,
   "David S. Miller" <davem@redhat.com>, <linux-net@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ethan Sommer <sommere@ethanet.com>
In-Reply-To: <3ECB9F6A.20004@ethanet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 21 May 2003, Ethan Sommer wrote:

> Philippe Biondi wrote:
>
> >regexp support was planned but not done yet. (if someone know where I =
can
> >download more free time !).
> >
> >The implementation should not be that hard, once you have the compiler=
 to
> >transform the string describing the regexp to an automaton.
> >
> >Note that to respect the framework, you have to deal with multiple
> >patterns (should not be that hard). If you have pat1 and pat2, searchi=
ng
> >for (pat1|pat2) is not sufficient because for each match, you have to
> >point which pattern matched.
> >
> >
>
> We actually planned on doing that initially. You should note that if yo=
u
> want to generate one automaton for multiple patterns, that is not a
> regular language (and thus can not be represented by a FA or DFA.)  You
> will have to try matching against the first pattern, then the next and
> so on.

If P and Q are regexps, P|Q is a regexp, so you do can.
So detection is clearly not a problem. But to fit in the libqsearch model=
,
you have to know which of the parterns matched. This is theorically
possible, but need a bit of work in comparison with using an
off-the-shelf regexp compiler on (Pat1|Pat2|..|Patn).



--=20
Philippe Biondi <biondi@ cartel-securite.fr> Cartel S=E9curit=E9
Security Consultant/R&D                      http://www.cartel-securite.f=
r
Phone: +33 1 44 06 97 94                     Fax: +33 1 44 06 97 99
PGP KeyID:3D9A43E2  FingerPrint:C40A772533730E39330DC0985EE8FF5F3D9A43E2
