From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net v2 3/3] packet: fix tpacket_snd max frame and vlan
 handling
Date: Wed, 11 Nov 2015 23:39:41 +0100
Message-ID: <5643C3AD.3000803@iogearbox.net>
References: <cover.1447191361.git.daniel@iogearbox.net> <f664dc9cf1d33a001fcdb0265833c96644db5bfd.1447191361.git.daniel@iogearbox.net> <CA+FuTSfkD4aMciGeqon0cLp=EJ7fWis56nGQsbku82ZC+=nNWg@mail.gmail.com> <564279DF.4080400@iogearbox.net> <CA+FuTSep5RRghDMbPJh-OcJDZo8BFr-9hyHBrdXiOh2vck4_zA@mail.gmail.com> <56428307.1010200@iogearbox.net> <CA+FuTSf9nY3PewO0=jDJ7ppv1RsriXg_S+w=owhXsAFKJYkZbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Tobias Klauser <tklauser@distanz.ch>,
	Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57939 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752480AbbKKWjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 17:39:46 -0500
In-Reply-To: <CA+FuTSf9nY3PewO0=jDJ7ppv1RsriXg_S+w=owhXsAFKJYkZbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/11/2015 03:56 PM, Willem de Bruijn wrote:
> On Tue, Nov 10, 2015 at 6:51 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
...
>> Saw that, so we need the check as one more fix for 57f89bfa2140 ("network:
>> Allow af_packet to transmit +4 bytes for VLAN packets.") as well.
>>
>> I'll see to respin a v3 tomorrow.
>
> Thanks, Daniel.
>
> The three existing uses of eth_hdr were applied in 2.6.39, 3.12 and 3.15.
> We probably need a patch per occurrence to allow backporting to the
> relevant stable branches. I can create the fixes independent from your
> patch set, if you prefer.

Thanks, I've pushed the new set out for review with the 3rd patch simplified
quite a bit. I think we could let this linger a bit in -net first, and in
case backporting help would be needed, happy to jump in.

Best & thanks,
Daniel
