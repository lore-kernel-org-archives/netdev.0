From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] team: refine IFF_XMIT_DST_RELEASE capability
Date: Wed, 18 Jul 2012 11:28:57 -0700 (PDT)
Message-ID: <20120718.112857.359268319352403956.davem@davemloft.net>
References: <1342633178-1411-1-git-send-email-jiri@resnulli.us>
	<1342635454.2626.3337.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755317Ab2GRS26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:28:58 -0400
In-Reply-To: <1342635454.2626.3337.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jul 2012 20:17:34 +0200

> On Wed, 2012-07-18 at 19:39 +0200, Jiri Pirko wrote:
>> Cloned patch of Eric Dumazet for bonding.
>> 
>> Some workloads greatly benefit of IFF_XMIT_DST_RELEASE capability
>> on output net device, avoiding dirtying dst refcount.
>> 
>> team currently disables IFF_XMIT_DST_RELEASE unconditionally.
>> 
>> If all ports have the IFF_XMIT_DST_RELEASE bit set, then
>> team dev can also have it in its priv_flags.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  drivers/net/team/team.c |    5 +++++
>>  1 file changed, 5 insertions(+)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
