From: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
Subject: Re: [Fwd: IPoIB]
Date: Thu, 30 May 2002 17:56:43 +0200 (MET DST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.05.10205301751370.9848-100000@mausmaki.cosy.sbg.ac.at>
References: <3CF61BE0.BDF0F05B@vieo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Joseph Golio <golio@vieo.com>
In-Reply-To: <3CF61BE0.BDF0F05B@vieo.com>
List-Id: netdev.vger.kernel.org

--snip/snip

> >     I have a question. I am working on developing a Linux driver for IP over
> > Infiniband (IPoIB) and
> >     have run into an issue that I need your advice. The draft standard from the
> > IETF on IPoIB
> >     encapsulation and address resolution over Infiniband networks (see the link
> > below - section 6.1.1)
> >     defines the hardware address as being 20 bytes in length. It appears that
> > the "netdevice.h" file in
> >     Linux has MAX_ADDR_LEN set to 7 (at least in my version which is SuSe 7.3 -


for 2.5.18 at least it's set to 8, but there is no reason to not change it to
20 beside wasting some memory

n time for
	a) broadcast address
	b) device address
	int netdevice
sum(m[n]) times for the multicast list

where n == number of network devices, m == number of MC entries per device
as i can see it.

and this "overhead" should be really acceptable :)

... probably you will break some "external" stuff like freeswan, but this
shouldn't be your problem.

	tm

-- 
in some way i do, and in some way i don't.
