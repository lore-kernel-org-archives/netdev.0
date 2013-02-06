From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: frto should not set snd_cwnd to 0
Date: Wed, 06 Feb 2013 15:55:04 -0500 (EST)
Message-ID: <20130206.155504.1553906005129825120.davem@davemloft.net>
References: <1359918785.30177.111.camel@edumazet-glaptop>
	<alpine.DEB.2.00.1302041327210.4561@wel-95.cs.helsinki.fi>
	<CADVnQymufg8YFCg3cBQzTW-WbYRYpG=FVqtd-A5tLUU=Uex_eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, eric.dumazet@gmail.com, pasik@iki.fi,
	hannes@stressinduktion.org, stephen@networkplumber.org,
	netdev@vger.kernel.org, ycheng@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758328Ab3BFUzI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 15:55:08 -0500
In-Reply-To: <CADVnQymufg8YFCg3cBQzTW-WbYRYpG=FVqtd-A5tLUU=Uex_eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Neal Cardwell <ncardwell@google.com>
Date: Tue, 5 Feb 2013 14:49:04 -0500

> On Mon, Feb 4, 2013 at 7:14 AM, Ilpo J=E4rvinen <ilpo.jarvinen@helsin=
ki.fi> wrote:
>> [PATCH 1/1] tcp: fix for zero packets_in_flight was too broad
>>
>> There are transients during normal FRTO procedure during which
>> the packets_in_flight can go to zero between write_queue state
>> updates and firing the resulting segments out. As FRTO processing
>> occurs during that window the check must be more precise to
>> not match "spuriously" :-). More specificly, e.g., when
>> packets_in_flight is zero but FLAG_DATA_ACKED is true the problemati=
c
>> branch that set cwnd into zero would not be taken and new segments
>> might be sent out later.
>>
>> Only compile tested.
>>
>> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
 ...
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks everyone.
