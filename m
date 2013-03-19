From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net-next 1/4] flow_keys: include thoff into flow_keys
 for later usage
Date: Tue, 19 Mar 2013 16:06:01 +0100
Message-ID: <51487ED9.5000200@redhat.com>
References: <cover.1363702456.git.dborkman@redhat.com>  <cc0d2911a173be99651dc39e77286aab260c3c19.1363702456.git.dborkman@redhat.com> <1363705390.2558.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jasowang@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27315 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757015Ab3CSPGG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 11:06:06 -0400
In-Reply-To: <1363705390.2558.3.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/2013 04:03 PM, Eric Dumazet wrote:
> On Tue, 2013-03-19 at 15:34 +0100, Daniel Borkmann wrote:
>> In skb_flow_dissect(), we perform a dissection of a skbuff. Since we're
>> doing the work here anyway, also store thoff for a later usage, e.g. in
>> the BPF filter. Also, by having thoff 16 Bit, we do not need to pack
>> flow_keys and reorder choke_skb_cb.
>>
>> Suggested-by: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   This patch also needs to go into the net tree, since Eric or Jason will
>>   post a bug fix on top of this one.
>>
>>   include/net/flow_keys.h   | 1 +
>>   net/core/flow_dissector.c | 5 ++++-
>>   2 files changed, 5 insertions(+), 1 deletion(-)
>
> Oh well, you left the choke_skb_cb description in changelog

But it's not the old changelog. ;-)

  Also, by having thoff 16 Bit, we do *not* need to pack flow_keys and
  reorder choke_skb_cb.

> Acked-by: Eric Dumazet <edumazet@google.com>
