From: Simon Chen <simonchennj@gmail.com>
Subject: Re: under-performing bonded interfaces
Date: Fri, 23 Dec 2011 10:03:31 -0500
Message-ID: <CANj2EbcATh4Zmjs2YMypCajjLzb0mF7HHit3KVmbfLX2mav5rA@mail.gmail.com>
References: <CANj2EbeMRzicixHwrKpCQ3mMqQ1qbyjbRCxpW+CmVRREAhyeRQ@mail.gmail.com>
	<4EC44ECB.4050201@candelatech.com>
	<CANj2EbfrtbysEbj+gMa+fOhWo0EWjBXVyGkw8WyiPAV9nPduuQ@mail.gmail.com>
	<1321491449.2709.90.camel@bwh-desktop>
	<CANj2Ebdd89=Fk6i4e4Txsb3ANuzz-x4t+tT6CAnWDNZe0zvx9g@mail.gmail.com>
	<1321498314.2885.78.camel@deadeye>
	<CANj2Eben0hrP6KwxyA1WPqiqzm84w=J2_sdtrKtGvxdftuksqg@mail.gmail.com>
	<1324532593.2621.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:62133 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752358Ab1LWPDc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Dec 2011 10:03:32 -0500
Received: by lahd3 with SMTP id d3so1291287lah.19
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 07:03:31 -0800 (PST)
In-Reply-To: <1324532593.2621.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's a funny thing again... I left the bandwidth test running
over-night - I used 16 simple senders and receivers.

The bandwidth slowly climbed from around 16G to 19G, which is much
better. I suspect two causes: 1) regular tcp implementation that has
slow-start and aggressive back-off; 2) user-land application...

-Simon

On Thu, Dec 22, 2011 at 12:43 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mercredi 21 d=E9cembre 2011 =E0 20:26 -0500, Simon Chen a =E9crit =
:
>> Hi folks,
>>
>> I added an Intel X520 card to both the sender and receiver... Now I
>> have two 10G ports on a PCIe 2.0 x8 slot (5Gx8), so the bandwidth of
>> the PCI bus shouldn't be the bottleneck.
>>
>> Now the throughput test gives me around 16Gbps in aggregate. Any ide=
as
>> how I can push closer to 20G? I don't quite understand where the
>> bottleneck is now.
>
> Could you post some "perf top" or "perf record / report" numbers ?
>
>
>
