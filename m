From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC PATCH 0/4] inet: add second hash table
Date: Wed, 30 May 2012 09:27:32 -0700
Message-ID: <4FC64A74.8000308@candelatech.com>
References: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>  <1338364640.2760.96.camel@edumazet-glaptop>  <CAEnQRZD3o_+fRnnbd74VeFuNvjAVVyq-rE241J96iRXWFDAEPQ@mail.gmail.com> <1338381662.2760.172.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Baluta <dbaluta@ixiacom.com>,
	Alexandru Copot <alex.mihai.c@gmail.com>, davem@davemloft.net,
	gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	Lucian Grijincu <lucian.grijincu@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35222 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128Ab2E3Q2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 12:28:34 -0400
In-Reply-To: <1338381662.2760.172.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2012 05:41 AM, Eric Dumazet wrote:
> On Wed, 2012-05-30 at 15:32 +0300, Daniel Baluta wrote:

> UDP case was a bit different, since production machine could really have
> thousand of UDP flows for tunnel terminations.
>
> But for TCP, unless your very specific needs I don't see the real need
> to review 400 lines of patches ?
>
> Nobody but you ever complained of listen() being performance critical
> with 16.000 IP on a machime...

Well, we do similar things and would probably benefit from this change...

If it would help, I'll add these to our kernels and run them through
some of our test cases..but will probably be a week or two at soonest...

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
