From: Joseph Golio <golio@vieo.com>
Subject: Re: [Fwd: IPoIB]
Date: Thu, 30 May 2002 11:13:45 -0500
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CF64FB9.A5F5CC21@vieo.com>
References: <Pine.GSO.4.05.10205301751370.9848-100000@mausmaki.cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, gary klesk <gklesk@vieo.com>,
   jeff young <jsy@vieo.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
List-Id: netdev.vger.kernel.org

Thomas 'Dent' Mirlacher wrote:

That's what I thought. Now, I can make the change to my local systems for
development and we could even give instructions to our customers to make
the change to their systems also. However, how would I get this change
propogated to the next release of the Linux kernel (2.5.18 plus...) ?

Thanks,

Joe

> --snip/snip
>
> > >     I have a question. I am working on developing a Linux driver for IP over
> > > Infiniband (IPoIB) and
> > >     have run into an issue that I need your advice. The draft standard from the
> > > IETF on IPoIB
> > >     encapsulation and address resolution over Infiniband networks (see the link
> > > below - section 6.1.1)
> > >     defines the hardware address as being 20 bytes in length. It appears that
> > > the "netdevice.h" file in
> > >     Linux has MAX_ADDR_LEN set to 7 (at least in my version which is SuSe 7.3 -
>
> for 2.5.18 at least it's set to 8, but there is no reason to not change it to
> 20 beside wasting some memory
>
> n time for
>         a) broadcast address
>         b) device address
>         int netdevice
> sum(m[n]) times for the multicast list
>
> where n == number of network devices, m == number of MC entries per device
> as i can see it.
>
> and this "overhead" should be really acceptable :)
>
> ... probably you will break some "external" stuff like freeswan, but this
> shouldn't be your problem.
>
>         tm
>
> --
> in some way i do, and in some way i don't.
