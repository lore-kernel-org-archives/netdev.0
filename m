From: Philippe Biondi <biondi@cartel-securite.fr>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: Thu, 22 May 2003 10:26:30 +0200 (CEST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.40.0305221019240.29409-100000@phil.home.phil>
References: <3ECC0B14.7020105@ethanet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi <hadi@shell.cyberus.ca>,
	Martin Josefsson <gandalf@wlug.westbo.se>,
	"David S. Miller" <davem@redhat.com>, <linux-net@vger.kernel.org>,
	<netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: Ethan Sommer <sommere@ethanet.com>
In-Reply-To: <3ECC0B14.7020105@ethanet.com>
List-Id: netdev.vger.kernel.org

> >
> I take it back, it is regular (kinda) but you can't to it with a
> deterministic finite atomaton. If there is a cycle in pattern1, off o=
f
> which pattern2 has a branch, then you would need to count how many ti=
mes
> you have gone around the cycle to know where to jump to in pattern2 i=
f
> it fails to match pattern1 (which you can't do, pumping lemma and all
> that.) If you use a non-determistic FA, you should be able to just go
> through each pattern until both crash or one matches and declare that
> the winner.


Strange way of reasoning... what if pattern1 is "(subpat1|subpat2)" ?
regexp is a regular language so it is equivalent to a DFA.
=46or every NDFA, there exist a DFA that recognize the same language.
So, it is possible.

The question is : will we have enough memory to store a DFA that recogn=
ize
a big regexp ? The answer is : let loose some speed and use NDFA.

> If your lib did that, it would work quite well for the layer-7 filter=
=2E

Anyone here interested by doing a regexp compiler ? I can help for deta=
ils
or libqsearch internals, but I won't find enough time to do all that
quickly enough.


--=20
Philippe Biondi <biondi@ cartel-securite.fr> Cartel S=E9curit=E9
Security Consultant/R&D                      http://www.cartel-securite=
=2Efr
Phone: +33 1 44 06 97 94                     Fax: +33 1 44 06 97 99
PGP KeyID:3D9A43E2  FingerPrint:C40A772533730E39330DC0985EE8FF5F3D9A43E=
2

