From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 18212] New: force_igmp_version ignored when a IGMPv3
 query received (+1 line patch)
Date: Tue, 14 Sep 2010 14:24:18 -0700 (PDT)
Message-ID: <20100914.142418.149835514.davem@davemloft.net>
References: <20100910091936.75eabbf6@nehalam>
	<OF1A09F28B.15E7E7BC-ON8825779E.00741A65-8825779E.007540E3@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44789
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755561Ab0INVYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 17:24:00 -0400
In-Reply-To: <OF1A09F28B.15E7E7BC-ON8825779E.00741A65-8825779E.007540E3@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Tue, 14 Sep 2010 14:20:40 -0700

> netdev-owner@vger.kernel.org wrote on 09/10/2010 09:19:36 AM:
> 
>> 
>> https://bugzilla.kernel.org/show_bug.cgi?id=18212
>> 
>>            Summary: force_igmp_version ignored when a IGMPv3 query
>>                     received (+1 line patch)
> 
>> 
>> Created an attachment (id=29512)
>>  --> (https://bugzilla.kernel.org/attachment.cgi?id=29512)
>> fix force_igmp_version v3 query problem
>> 
>> After all these years, it turns out that the
>>     /proc/sys/net/ipv4/conf/*/force_igmp_version
>> parameter isn't fully implemented.
> 
>         I don't think it's correct to send a v2 response to a v3
> query in any case. The question for answering v3 queries was
> whether to answer them with a v3 report, or to drop them and
> ignore them when force_igmp_version==2. I chose to respond,
> but I can see the case for dropping it too. I don't agree that
> a v3 query should be answered with a v2 resport (a real v2
> host would drop it).

Do you have an alternative patch to suggest?
