From: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe
 RLT-8139 related)
Date: Wed, 4 Aug 2004 19:26:03 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0408041915510.14609-100000@silmu.st.jyu.fi>
References: <Pine.LNX.4.44.0408032256110.2281-100000@silmu.st.jyu.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        H?ctor Mart?n <hector@marcansoft.com>,
        Linux-Kernel <linux-kernel@vger.kernel.org>, <akpm@osdl.org>,
        <netdev@oss.sgi.com>, <brad@brad-x.com>, <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <Pine.LNX.4.44.0408032256110.2281-100000@silmu.st.jyu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 Aug 2004, Pasi Sjoholm wrote:

> > If you remove the "if (received > 0) {" test in r8139-10.patch and ke=
ep
> > both patches applied, I assume you are back to a crash within 15min (=
instead
> > of within 2min as suggested by the log), right ?
> I removed "if (received > 0) {" and tested it something like 3 hours an=
d=20
> wasn't able to crash the driver. I will test it for couple more hours=20
> tomorrow and if I'm not still able the crash it, we may have find some=20
> sort of a solution.
> I'm not sure yet if it's a good one because of that earlier crash I had.
> I guess I will also test if
> "- read the interruption status word that the driver will ack before th=
e
>   actual processing is done;" has something to do with it.

Ok, now I have tested it for 6 hours without crashing the driver. The=20
system's load has been something like 5-6 the whole time. I also made som=
e=20
network load with ~90Mbps-incoming and ~90Mbps-outgoing traffic.=20

I haven't had time to test anything else but I'm quite sure that there is=
=20
no need for that anymore because the stability we have reached.=20

I'll let you know if there's any problems within next few days but I woul=
d=20
recommend that those patches would be included in 2.6.8. (without that "i=
f=20
(received > 0) {").

Many thanks for your help to resolve this problem.=20

Hector, have you tested these patches?

--
Pasi Sj=F6holm
