From: tsuna <tsunanet@gmail.com>
Subject: Re: [PATCH] tcp: Implement a two-level initial RTO as per draft RFC 2988bis-02.
Date: Thu, 19 May 2011 09:40:09 -0700
Message-ID: <BANLkTimSZEbnNVzi3UvBFndHp25S0ow7YQ@mail.gmail.com>
References: <1305771744-83951-1-git-send-email-tsunanet@gmail.com>
 <20110518.223622.1525088601595365235.davem@davemloft.net> <BANLkTinEN_=jSCw4qR1PqtWaQ+07OMq7tg@mail.gmail.com>
 <20110519.001426.2119532755281545481.davem@davemloft.net> <BANLkTikQEq9+YkJHcTe3PWnRvh7AN=VVWA@mail.gmail.com>
 <9DC9A4D5-8E16-4361-B323-C92D563171A1@comsys.rwth-aachen.de>
 <BANLkTimVMYC5rzizaM+3dReG14obxGL=Bw@mail.gmail.com> <C70B920C-6176-481B-B6D2-E52769291EBC@comsys.rwth-aachen.de>
 <BANLkTiku9KTHCm59cib5KY8mz0ewSLsHFQ@mail.gmail.com> <8C5DF277-320D-4DEB-A133-EEC301DE58DC@comsys.rwth-aachen.de>
 <ef84de89c2597793d4cca5eee446ba90@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ef84de89c2597793d4cca5eee446ba90@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 19, 2011 at 1:02 AM, Hagen Paul Pfeifer <hagen@jauu.net> wr=
ote:
> So yes, it CAN be wise to choose other lower/upper bounds. But keep i=
n
> mind that we should NOT artificial limit ourself. I can image data ce=
nter
> scenarios where a initial RTO of <1 match perfectly.

Yes that's exactly the point I was trying to make when talking to
Alexander offline.  On today's Internet, RTTs are easily in the
hundreds of ms, and initRTO is 3s, so there's 2 orders of magnitude of
difference.  In my environment, if my RTT is ~2=B5s, an initRTO of 200m=
s
means that there's a gap of 6 orders of magnitude (!).  And yes,
although I don't work for High Frequency Trading companies in Wall
Street, I'm already buying switches full of line-rate 10Gb ports with
a port-to-port latency of 500ns for L2/L3 forwarding/switching.  I
expect this kind of network gear will quickly become prevalent in
datacenter/backend environments.

--=20
Benoit "tsuna" Sigoure
Software Engineer @ www.StumbleUpon.com
