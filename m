From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next] net: bcmgenet: simplify __bcmgenet_tx_reclaim()
Date: Fri, 27 Feb 2015 15:50:59 -0800
Message-ID: <CAGXr9JEsdo=dMH3uWmqKArZFFLETUbaHMFTxZKdOzhmOhriHmg@mail.gmail.com>
References: <20150225185500.C7EBC2211C6@puck.mtv.corp.google.com>
	<54F0ED2A.9040306@gmail.com>
	<1425080378.5130.50.camel@edumazet-glaptop2.roam.corp.google.com>
	<54F100F7.7000709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:46750 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755393AbbB0XvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 18:51:00 -0500
Received: by qcxr5 with SMTP id r5so16628670qcx.13
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 15:50:59 -0800 (PST)
In-Reply-To: <54F100F7.7000709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'll be submitting patches soon for multiple Rx queues and Hardware
Filter Block.

-- Petri

On Fri, Feb 27, 2015 at 3:42 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 27/02/15 15:39, Eric Dumazet wrote:
>> On Fri, 2015-02-27 at 14:18 -0800, Florian Fainelli wrote:
>>> On 25/02/15 10:55, Petri Gynther wrote:
>>
>>> Nice cleanups!
>>>
>>>>
>>>> Signed-off-by: Petri Gynther <pgynther@google.com>
>>>
>>> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>>
>> Is any one working adding BQL & xmit_more on this driver ?
>
> I have this on my todo, but I would need Jaedon's patch which move tx
> completion to NAPI before submitting these.
> --
> Florian
