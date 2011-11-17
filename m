From: Simon Chen <simonchennj@gmail.com>
Subject: Re: under-performing bonded interfaces
Date: Wed, 16 Nov 2011 20:38:08 -0500
Message-ID: <CANj2Ebdd89=Fk6i4e4Txsb3ANuzz-x4t+tT6CAnWDNZe0zvx9g@mail.gmail.com>
References: <CANj2EbeMRzicixHwrKpCQ3mMqQ1qbyjbRCxpW+CmVRREAhyeRQ@mail.gmail.com>
	<4EC44ECB.4050201@candelatech.com>
	<CANj2EbfrtbysEbj+gMa+fOhWo0EWjBXVyGkw8WyiPAV9nPduuQ@mail.gmail.com>
	<1321491449.2709.90.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42428 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755313Ab1KQBiJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 20:38:09 -0500
Received: by fagn18 with SMTP id n18so2313962fag.19
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 17:38:08 -0800 (PST)
In-Reply-To: <1321491449.2709.90.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, Ben. That's good discovery...

Are you saying that both 10G NICs are on the same PCIe x4 slot, so
that they're subject to the 12G throughput bottleneck?

I'm gonna verify this with the hardware vendor...

Thanks.
-Simon

On Wed, Nov 16, 2011 at 7:57 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Wed, 2011-11-16 at 19:05 -0500, Simon Chen wrote:
>> If used independently, I can get around 9.8Gbps.
> [...]
>> [ =A0 11.572861] ixgbe 0000:03:00.0: (PCI Express:5.0Gb/s:Width x4) =
e8:9a:8f:23:42:1a
> [...]
>
> You need a PCIe 2.0 x8 slot to run 2 10 Gb ports at full speed. =A0An=
 x4
> slot is only good for about 12-13 Gb aggregate throughput (dependent =
on
> packet sizes and other details).
>
> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
