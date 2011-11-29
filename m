From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 05:23:10 +0100
Message-ID: <CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:47101 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041Ab1K2EXL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 23:23:11 -0500
Received: by ggnr5 with SMTP id r5so6006576ggn.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 20:23:11 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> In this test 100 netperf TCP_STREAMs were started to saturate the lin=
k.
> A single instance of a netperf TCP_RR was run with high priority set.
> Queuing discipline in pfifo_fast, NIC is e1000 with TX ring size set =
to
> 1024. =A0tps for the high priority RR is listed.
>
> No BQL, tso on: 3000-3200K bytes in queue: 36 tps
> BQL, tso on: 156-194K bytes in queue, 535 tps

> No BQL, tso off: 453-454K bytes int queue, 234 tps
> BQL, tso off: 66K bytes in queue, 914 tps


Jeeze. Under what circumstances is tso a win? I've always
had great trouble with it, as some e1000 cards do it rather badly.

I assume these are while running at GigE speeds?

What of 100Mbit? 10GigE? (I will duplicate your tests
at 100Mbit, but as for 10gigE...)

I would suggest TCP_MAERTS as well to saturate the
link in the other direction.

And then both TCP_STREAM and
TCP_MAERTS at the same time while doing RR.


--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
