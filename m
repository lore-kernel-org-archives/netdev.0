From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI-ized tulip patch against 2.4.20-rc1
Date: Thu, 7 Nov 2002 07:48:49 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211070741380.11183-100000@shell.cyberus.ca>
References: <15817.21170.173913.829498@robur.slu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Greear <greearb@candelatech.com>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
   Jeff Garzik <jgarzik@mandrakesoft.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <15817.21170.173913.829498@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 6 Nov 2002, Robert Olsson wrote:

>
>  Well skb recycling is "research" and should be used to challange to vm/slab
>  people to start with... And I guess you will get objections about the extra
>  stats as well.

It's ok for syncing with current kernel driver i suppose.
The patch that should be considered for merging really is:
http://www.cyberus.ca/~hadi/patches/tulip-2419-napi-nifd.gz

which looks suspiciouly similar to his patch if you remove the
experimental stuff.

>
>  I see you increased the RX-ring to 1024 pkts.
>  Did you really see any improvement with this?
>
>  Also I would be interested if you have any numbers for recycling patch?
>
>  Jamal and I spent some days after OLS to test and tune but it wasn't to
>  promising at that time but it's reworked now.
>

I think the numbers we saw were upto 20% increase with uniprocessor (AMD
1Gig) and about 5% increase with dual SMP(PII-450s). In the case of SMP,
we concluded that the slab was screwing us.
In any case, this WIP ...

cheers,
jamal
