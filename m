From: Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org>
Subject: Re: RCU'ed dst_get_neighbour()
Date: Tue, 29 Nov 2011 18:17:14 -0700 (Mountain Standard Time)
Message-ID: <alpine.WNT.2.00.1111291815410.1288@TSI>
References: <alpine.WNT.2.00.1111291027320.1036@TSI> <1322589661.2596.2.camel@edumazet-laptop> <1322599437.2596.10.camel@edumazet-laptop> <CAG4TOxNJfr3X1p358LBWdNQKdkw8KOSekcKpNu6K5_phPEiR4A@mail.gmail.com> <1322599991.2596.11.camel@edumazet-laptop>
 <alpine.WNT.2.00.1111291359290.1036@TSI> <1322601444.2596.21.camel@edumazet-laptop> <1322602283.2596.25.camel@edumazet-laptop> <CAL1RGDUcYJKBSCthTL1AFgpRvzjoaEpHjGFhratKP-98ufRKnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDUcYJKBSCthTL1AFgpRvzjoaEpHjGFhratKP-98ufRKnw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Nov 2011, Roland Dreier wrote:
> On Tue, Nov 29, 2011 at 1:31 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> Here is the result of this audit, please double check and test it, I
>> only compiled this.

> Thanks Eric... I'll queue this up and send it on once we get a good
> report from Marc.

I can confirm that Eric's patch, retrofitted to 3.1.3, fixes the problem.

Marc.

+----------------------------------+----------------------------------+
|  Marc Aurele La France           |  work:   1-780-492-9310          |
|  Academic Information and        |  fax:    1-780-492-1729          |
|    Communications Technologies   |  email:  tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org         |
|  352 General Services Building   +----------------------------------+
|  University of Alberta           |                                  |
|  Edmonton, Alberta               |    Standard disclaimers apply    |
|  T6G 2H1                         |                                  |
|  CANADA                          |                                  |
+----------------------------------+----------------------------------+
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
