From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rps: some comments
Date: Fri, 08 Jan 2010 07:27:31 +0100
Message-ID: <4B46D053.3000604@gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>	 <20091120154046.67252d23@nehalam>	 <65634d660912171304p751e1698mbc9de50dade4317d@mail.gmail.com>	 <65634d661001051732qd64e79dt37e6247f8b0dc863@mail.gmail.com>	 <4B44258C.2050302@gmail.com> <4B44D89B.8070006@gmail.com>	 <65634d661001061454v389d311fjb245de21e0ab8092@mail.gmail.com>	 <4B45A623.7070507@gmail.com> <4B461D11.6050603@gmail.com> <65634d661001071607k63c33a0q4f402942d64ea77e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43904 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982Ab0AHG1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 01:27:39 -0500
In-Reply-To: <65634d661001071607k63c33a0q4f402942d64ea77e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/01/2010 01:07, Tom Herbert a =E9crit :
> I kind of like the way it is right now, which is to enqueue even on
> the local CPU.  The advantage of that is that all the packets receive=
d
> in the napi run are dispatched to all the participating CPUs before
> any are processed, this is good for average and worst case latency on
> a packet burst.

I see... this makes sense, thanks.

Do you know if some non multi queue NIC would be able to provide us
a suitable hash to fill skb->rxhash in NIC driver itself ?

