From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: make br_parse_ip_options static
Date: Thu, 21 Oct 2010 03:12:35 -0700 (PDT)
Message-ID: <20101021.031235.112594832.davem@davemloft.net>
References: <20101018170321.2b0de4ea@nehalam>
	<20101019112234.GB12005@stratus.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: bandan.das@stratus.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60497
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755328Ab0JUKMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:12:12 -0400
In-Reply-To: <20101019112234.GB12005@stratus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bandan Das <bandan.das@stratus.com>
Date: Tue, 19 Oct 2010 07:22:34 -0400

> On  0, Stephen Hemminger <shemminger@vyatta.com> wrote:
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>> 
>> --- a/net/bridge/br_netfilter.c	2010-10-18 17:01:36.903364885 -0700
>> +++ b/net/bridge/br_netfilter.c	2010-10-18 17:01:48.106569141 -0700
>> @@ -213,7 +213,7 @@ static inline void nf_bridge_update_prot
>>   * expected format
>>   */
>>  
>> -int br_parse_ip_options(struct sk_buff *skb)
>> +static int br_parse_ip_options(struct sk_buff *skb)
>>  {
>>  	struct ip_options *opt;
>>  	struct iphdr *iph;
>> 
> 
> My main motivation behind not making this static was that
> there would be possibly other places in the bridge code 
> (besides br_netfilter.c) where we enter the IP stack and might 
> want to call this. Not sure if it's indeed the case though..

You can un-static it when the use is added.

Patch applied, thanks Stephen.
