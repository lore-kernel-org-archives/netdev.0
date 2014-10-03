From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next PATCH V6 0/2] qdisc: bulk dequeue support
Date: Fri, 3 Oct 2014 15:19:24 -0700
Message-ID: <CA+mtBx_TQhbS3VPVKjosaQjyO8YkNi=zBQMVYEbLqR8Hyczd3Q@mail.gmail.com>
References: <20141001203345.3321.99675.stgit@dragon>
	<20141003.123806.183331913071081861.davem@davemloft.net>
	<1412369869.17245.4.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141003.145647.1980640682969765484.davem@davemloft.net>
	<1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412374535.17245.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:61825 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932254AbaJCWTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:19:25 -0400
Received: by mail-ig0-f177.google.com with SMTP id a13so80615igq.10
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 15:19:24 -0700 (PDT)
In-Reply-To: <1412374535.17245.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 3, 2014 at 3:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-10-03 at 14:57 -0700, Eric Dumazet wrote:
>> On Fri, 2014-10-03 at 14:56 -0700, David Miller wrote:
>>
>> > I completely agree, and I sort of intended this to happen when
>> > I split all the code into that new function.
>> >
>> >   GSO segmentation of TX checksuming should not prevent other
>> > > cpus from queueing other skbs in the qdisc.
>> > >
>> > > I will spend some time on this.
>> >
>> > Thanks!
>>
>> I just did my first reboot, will make sure everything is working well
>> before sending the patch ;)
>
> This is awesome...
>
> 40Gb rate, with TSO=on or TSO=off, it does not matter anymore.
>
This is with or without GSO?

>
>
