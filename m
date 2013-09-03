From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: use reciprocal_divide instead of reimplementing
 it
Date: Tue, 03 Sep 2013 16:35:35 +0200
Message-ID: <5225F3B7.2000202@redhat.com>
References: <1378204010-27050-1-git-send-email-dborkman@redhat.com>  <1378204010-27050-3-git-send-email-dborkman@redhat.com> <1378216954.7360.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54918 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756454Ab3ICOfm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 10:35:42 -0400
In-Reply-To: <1378216954.7360.25.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2013 04:02 PM, Eric Dumazet wrote:
> On Tue, 2013-09-03 at 12:26 +0200, Daniel Borkmann wrote:
>> Replace these places with reciprocal_divide() inline function instead of
>> reimplementing it each time, thus it will become easier to read. We do not
>> need to explicitly include its header as it's pulled in from linux/net.h
>> anyway.
>
> Sure, (((u64) hash * qcount) >> 32) happens to be
> reciprocal_divide(hash, qcount) but the result depends on hash being
> well distributed in [0 .. ~0U] space.
>
> So 'reciprocal' and 'divide' do not accurately describe this exact
> operation.
>
> I suggest making the thing more descriptive.
>
> (And discussed on lkml btw)

Sure, we can do that. Then lets drop these two for now.
