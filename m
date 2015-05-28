From: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Subject: Re: Drops in qdisc on ifb interface
Date: Thu, 28 May 2015 13:54:31 -0400 (EDT)
Message-ID: <1813033466.134788.1432835671936.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
References: <1432584300.32671.103.camel@jasiiieee.pacifera.com> <1432593064.4060.190.camel@edumazet-glaptop2.roam.corp.google.com> <1767970154.119773.1432823923389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net> <1432826085.7456.6.camel@edumazet-glaptop2.roam.corp.google.com> <746223891.124020.1432827038389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net> <5567382E.4010706@gmail.com> <1432830406.7456.19.camel@edumazet-glaptop2.roam.corp.google.com> <133859123.129202.1432830817627.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net> <1432833476.7456.21.camel@edumazet-glaptop2.roam.corp.google.com> <2104973120.133348.1432834303388.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net> <1432835387.7456.23.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.196]:59421 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754014AbbE1Ryd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 13:54:33 -0400
In-Reply-To: <1432835387.7456.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On May 28, 2015 at 1:49 PM Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>
> On Thu, 2015-05-28 at 13:31 -0400, jsullivan@opensourcedevel.com wrote:
>
> > The overall product does but the video source feeds come over a different
> > network via UDP. There are, however, RTMP quality control feeds coming
> > across
> > this connection. There may also occasionally be test UDP source feeds on
> > this
> > connection but those are not production. Thanks - John
>
> This is important to know, because UDP wont benefit from GRO.
>
> I was assuming your receiver had to handle ~88000 packets per second,
> so I was doubting it could saturate one core,
> but maybe your target is very different.
>
>
>
That PPS estimate seems accurate - the port speed and CIR on the shaped
connection is 1 Gbps.

I'm still mystified by why the GbE bottlenecks on IFB but the 10GbE does not.
 Thanks -  John
