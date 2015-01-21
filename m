From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/3] openvswitch: Add STT support.
Date: Wed, 21 Jan 2015 12:22:29 -0800
Message-ID: <1421871749.4832.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421785536-19793-1-git-send-email-pshelar@nicira.com>
	 <CA+mtBx90TipY9uJvW2uQfrCYL9JNM9Rk75HzdJPhE0qsdy8dnw@mail.gmail.com>
	 <CALnjE+rSXpPftiG4Vw3azkN2s2-Ey6ZcZr9Bv422pOdwrvU=tw@mail.gmail.com>
	 <CA+mtBx9yM+C8GeEHOGTHPVxNB3fJd7LQG0RaC3jywrO9_tQ58A@mail.gmail.com>
	 <CALnjE+po5gy7g8ftmiNcnrN_gRL9tzCRHNtn=fxUafFikKB1rg@mail.gmail.com>
	 <CA+mtBx-v5dvX-OPGeWJb6uwQGhJ5T6iewD83xJGqXb+Ggf+LQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pravin Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:50704 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbbAUUWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 15:22:34 -0500
Received: by mail-ie0-f181.google.com with SMTP id rp18so5114618iec.12
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 12:22:32 -0800 (PST)
In-Reply-To: <CA+mtBx-v5dvX-OPGeWJb6uwQGhJ5T6iewD83xJGqXb+Ggf+LQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-21 at 11:45 -0800, Tom Herbert wrote:
> > I used bare metal intel servers. All VXLAN tests were done using linux
> > kernel device without any VMs. All STT tests are done using OVS bridge
> > and STT port.
> >
> So right off the bat you're running the baseline differently than the
> target. Anyway, I cannot replicate your numbers for VXLAN, I see much
> better performance and this with pretty old servers and dumb NICs. I
> suspect you might not have GSO/GRO properly enabled, but instead of
> trying to debug your setup, I'd rather restate my request that you
> provide a network interface to STT so we can do our own fair
> comparison.

I have not read specs nor the patch, but I would expect that with a TCP
stream, you simply can coalesce as many inner segments as you want.

So you could build a single TSO packet containing 400 'messages' of 160
bytes or so.

Something that a datagram tunneling cannot really do, assuming you want
full offloading support.
