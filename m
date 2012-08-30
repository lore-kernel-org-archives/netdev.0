From: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Subject: Re: [PATCH 1/1] tcp: Wrong timeout for SYN segments
Date: Thu, 30 Aug 2012 11:04:21 -0700
Message-ID: <CAFbMe2P-QhdkGGp=K6mdiW=g3CB_Z0C=Q8y=nz-nV6h2Q6WkcQ@mail.gmail.com>
References: <1346230305.2522.15.camel@edumazet-glaptop>
	<CAFbMe2PG90X7s6s970+XK3X0Jvzx4p6vhvM+JQCwtULPvs1QLw@mail.gmail.com>
	<1346332350.2586.10.camel@edumazet-glaptop>
	<20120830.124543.1590020152319166487.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, alex@linlab.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120830.124543.1590020152319166487.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 30, 2012 at 9:45 AM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 30 Aug 2012 06:12:30 -0700
>
>> On Wed, 2012-08-29 at 10:25 -0700, H.K. Jerry Chu wrote:
>>
>>> But it probably matter slightly more for TCP Fast Open (the server
>>> side patch has
>>> been completed and will be posted soon, after I finish breaking it up
>>> into smaller
>>> pieces for ease of review purpose), when a full socket will be created with data
>>> passed to the app upon a valid SYN+data. Dropping a fully functioning socket
>>> won't be the same as dropping a request_sock unknown to the app and letting
>>> the other side retransmitting SYN (w/o data this time).
>>>
>>> >
>>> > Sure, RFC numbers are what they are, but in practice, I doubt someone
>>> > will really miss the extra SYNACK sent after ~32 seconds, since it would
>>> > matter only for the last SYN attempted.
>>>
>>> I'd slightly prefer 1 extra retry plus longer wait time just to make
>>> TCP Fast Open
>>> a little more robust (even though the app protocol is required to be
>>> idempotent).
>>> But this is not a showstopper.
>>
>> Thats very good points indeed, thanks.
>>
>> Maybe we can increase SYNACK max retrans only if the FastOpen SYN cookie
>> was validated.
>>
>> This way, we increase reliability without amplifying the effect of wild
>> SYN packets.
>
> Can we come to a final conclusion on this last point and arrive at a final
> patch?
>
> Thanks.

Acked-by: H.K. Jerry Chu <hkchu@google.com>
