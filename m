From: Simon Chen <simonchennj@gmail.com>
Subject: Re: under-performing bonded interfaces
Date: Wed, 21 Dec 2011 20:26:04 -0500
Message-ID: <CANj2Eben0hrP6KwxyA1WPqiqzm84w=J2_sdtrKtGvxdftuksqg@mail.gmail.com>
References: <CANj2EbeMRzicixHwrKpCQ3mMqQ1qbyjbRCxpW+CmVRREAhyeRQ@mail.gmail.com>
	<4EC44ECB.4050201@candelatech.com>
	<CANj2EbfrtbysEbj+gMa+fOhWo0EWjBXVyGkw8WyiPAV9nPduuQ@mail.gmail.com>
	<1321491449.2709.90.camel@bwh-desktop>
	<CANj2Ebdd89=Fk6i4e4Txsb3ANuzz-x4t+tT6CAnWDNZe0zvx9g@mail.gmail.com>
	<1321498314.2885.78.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:36507 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751850Ab1LVB0H convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Dec 2011 20:26:07 -0500
Received: by lahd3 with SMTP id d3so748927lah.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 17:26:05 -0800 (PST)
In-Reply-To: <1321498314.2885.78.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

I added an Intel X520 card to both the sender and receiver... Now I
have two 10G ports on a PCIe 2.0 x8 slot (5Gx8), so the bandwidth of
the PCI bus shouldn't be the bottleneck.

Now the throughput test gives me around 16Gbps in aggregate. Any ideas
how I can push closer to 20G? I don't quite understand where the
bottleneck is now.

Thanks.
-Simon

On Wed, Nov 16, 2011 at 9:51 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Wed, 2011-11-16 at 20:38 -0500, Simon Chen wrote:
>> Thanks, Ben. That's good discovery...
>>
>> Are you saying that both 10G NICs are on the same PCIe x4 slot, so
>> that they're subject to the 12G throughput bottleneck?
>
> I assumed you were using 2 ports on the same board, i.e. the same slo=
t.
> If you were using 1 port each of 2 boards then I would have expected
> them both to be usable at full speed. =A0So far as I can remember, PC=
Ie
> bridges are usually set up so there isn't contention for bandwidth
> between slots.
>
> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
