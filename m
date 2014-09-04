From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC net-next PATCH V2 0/3] qdisc bulk dequeuing and utilizing
 delayed tailptr updates
Date: Thu, 04 Sep 2014 09:44:05 -0400
Message-ID: <54086CA5.6040209@mojatatu.com>
References: <20140904125247.4108.8132.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:46187 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbaIDNoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 09:44:13 -0400
Received: by mail-ie0-f175.google.com with SMTP id y20so11718208ier.20
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 06:44:12 -0700 (PDT)
In-Reply-To: <20140904125247.4108.8132.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/14 08:54, Jesper Dangaard Brouer wrote:
> Wanted people to review this work early... so this is the current
> state, even added my debug patch, if people want to "see" it work.
>

It would be useful to collect some stats when you are
experimenting with this stuff on the average batch size the driver
sees. Maybe a histogram which shows >1, > 3, > 10 etc that a
driver was able to chew on at a time. I realize this may skew
your results a little because you have to chew cycles updating
such a histogram.

I believe that any dumb traffic generator will show lots of packets
being batched. But that is not very interesting.
It would be hard to show more than 1 in the general case for
other types of traffic - but learning what else needs to be tweaked
to achive more batch sizes would be helpful.

i.e this would help quantify whether the batching is valuable in the
general sense...

cheers,
jamal
