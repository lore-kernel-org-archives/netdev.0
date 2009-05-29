From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/5] netdev: bfin_mac: Blackfin EMAC
	interrupt may not be shared
Date: Fri, 29 May 2009 18:21:41 -0400
Message-ID: <8bd0f97a0905291521m35731e0bra828cb09d0929974@mail.gmail.com>
References: <8bd0f97a0905290445x3b0829f3h657fec534f290c7f@mail.gmail.com>
	 <20090529.150928.239765896.davem@davemloft.net>
	 <8bd0f97a0905291513m780898e9j6bd4c0b3b9ae8528@mail.gmail.com>
	 <20090529.151816.232829085.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael.Hennerich@analog.com, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:59867 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824AbZE2WVk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 18:21:40 -0400
Received: by yw-out-2324.google.com with SMTP id 5so3611506ywb.1
        for <netdev@vger.kernel.org>; Fri, 29 May 2009 15:21:41 -0700 (PDT)
In-Reply-To: <20090529.151816.232829085.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2009 at 18:18, David Miller wrote:
> From: Mike Frysinger <vapier.adi@gmail.com>
>> the difference is that one of these is required in order for anythin=
g
>> to get done and the other is always useless noise. =C2=A0also, the B=
lackfin
>> core does do speculative data fetching on external memory, but not
>> MMRs, so the stalling due to the data cache line fills will be
>> mitigated unlike the useless MMR reads.
>
> You only need to read the register if the descriptor status is not
> ready yet, and you're just spinning in that case anyways.
>
> I doubt it makes any real difference if implemented properly.
>
> But I guess it's more fun to speculate than to actually try it out.
> :-/

and i guess it's more fun to waste time attempting to support an
operating mode that the hardware has never and most likely will never
support
-mike
