From: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe
 RLT-8139 related)
Date: Wed, 28 Jul 2004 00:27:26 +0300 (EEST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0407272348590.13195-100000@silmu.st.jyu.fi>
References: <16646.47585.814327.628319@robur.slu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	H?ctor Mart?n <hector@marcansoft.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>, <akpm@osdl.org>,
	<netdev@oss.sgi.com>, <brad@brad-x.com>, <shemminger@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S266615AbUG0V1y@vger.kernel.org>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16646.47585.814327.628319@robur.slu.se>
List-Id: netdev.vger.kernel.org

On Tue, 27 Jul 2004, Robert Olsson wrote:

>  > Yeah, when the ksoftirqd is taking all the cpu it will be like tha=
t, but=20
>  > when the kernel is behaving normally the starving diff is between =
0->1sec.
>  Well ksoftirqd makes your kernel load just visible which is good and=
=20
>  ksofirqd gets accounted for this when softirq's get deferred to it.
>  It may look like goes from 0 to 100% but thats probably not the case=
=2E
>  The problem is we can starve userland at high loads. As said we were
>  trying some way to cure this I may have some old patch if you like t=
o try.

Ok, as I said before I'm willing to test your patches.=20

It would be nice that one could use the full capacity of his/her comput=
er.
This is not a big problem for everyday use for a workstation but preven=
ts=20
2.6-series to be used in production-enviroments in the servers.
But hey.. we need to do some work and maybe we will resolve this. =3D)

--
Pasi Sj=F6holm
