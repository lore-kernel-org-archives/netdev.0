From: kuznet@ms2.inr.ac.ru
Subject: Re: net/ipv6/exthdrs.c
Date: Tue, 18 Jun 2002 23:03:41 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200206181903.XAA13710@sex.inr.ac.ru>
References: <20020618135149.A24751@sch.bme.hu>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kisza@securityaudit.HU (Andras Kis-Szabo)
In-Reply-To: <20020618135149.A24751@sch.bme.hu> from "Andras Kis-Szabo" at Jun 18, 2 04:15:01 pm
List-Id: netdev.vger.kernel.org

Hello!

> Is there any plan to add the ESP header to the ipv6_ext_hdr() function (as a
> known header)?

No, ESP is not a normal extension header, it terminates parse.
So, ipv6_skip_headers cannot skip it.

BTW the same is with netfilter. I do not see how are you going to use it. :-)

> (It requires changes in this file and in the icmp.c at the first round.)

I am afraid this will simply break the function.


> If this functon remains untouched, I'll add an another one into the Netfilter
> code (which can be used at the special matches).

This may be right even not depending on this issue. Goals are different:
the function in exthdrs.c does the best efforts to guess what protocol
is, the function in netfilter should be paranoid.

Alexey
