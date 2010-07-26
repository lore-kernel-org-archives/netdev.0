From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Splice status
Date: Mon, 26 Jul 2010 22:37:52 +0200
Message-ID: <4C4DF220.1050307@gmail.com>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>	 <AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>	 <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>	 <1278334254.2877.158.camel@edumazet-laptop>	 <AANLkTim_eBmT-6HmkqG5d7k0jjrGKAFBjzqVCricTpgK@mail.gmail.com>	 <1278388580.2466.305.camel@edumazet-laptop>	 <AANLkTinRnDwMOS5NrmzKqYZpczG4nfHSvKA9Gw-_UUzO@mail.gmail.com>	 <EE71107DF0D1F24FA2D95041E64AB9E8ED254E7B66@IL-MB01.marvell.com> <1279030308.2634.349.camel@edumazet-laptop> <EE71107DF0D1F24FA2D95041E64AB9E80114797BC8AB@IL-MB01.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>, Jens Axboe <axboe@kernel.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ofer Heifetz <oferh@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61350 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755326Ab0GZUiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 16:38:05 -0400
Received: by bwz1 with SMTP id 1so2992240bwz.19
        for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 13:38:03 -0700 (PDT)
In-Reply-To: <EE71107DF0D1F24FA2D95041E64AB9E80114797BC8AB@IL-MB01.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ofer Heifetz wrote, On 25.07.2010 16:47:

> Hi Eric,
> 
> Still trying to get better performance with splice, I noticed that when using splice there are twice the file size memcpy (placed a counter in memcpy), I verified it via samba file transfer and splice-fromnet/out.
> 
> I also used the splice-fromnet/out and using ftrace I did notice that data is copied twice using these routines: skb_splice_bits, pipe_to_file.


I'm not sure you're using optimal NIC for splice, which should use
skbs with almost all data paged (non-linear), like niu or myri10ge.

Jarek P.
