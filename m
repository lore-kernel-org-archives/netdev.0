From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next-2.6 3/3] bonding,ipv4,ipv6,vlan: Handle NETDEV_BONDING_FAILOVER
 like NETDEV_NOTIFY_PEERS
Date: Tue, 19 Apr 2011 15:34:00 -0400
Message-ID: <4DADE3A8.3040206@hp.com>
References: <1302911271.2845.41.camel@bwh-desktop> <22334.1302913805@death> <1303153792.2857.32.camel@bwh-desktop> <26398.1303240321@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:18753 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044Ab1DSTeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 15:34:04 -0400
In-Reply-To: <26398.1303240321@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2011 03:12 PM, Jay Vosburgh wrote:
>>> 	Brian Haley added the unsolicited NAs; I've added him to the cc
>>> so perhaps he (or somebody else) can comment on the necessity of keeping
>>> the ability to send multiple NAs.
>> [...]
>>
>> How about restoring the parameters like this:
> 
> 	I think the patch below is better than Brian's suggestion (new
> single parameter) because it won't break existing configurations, even
> though it is doing magic under the covers.  If the magic is a real
> concern, we could add logic to detect when both parameters are used and
> set to different values, but I'm not really that worked up about it as
> long as the magic is clearly documented.

My patch was on-top of Ben's, it still left the old options around, just
gave people time to notice they didn't work as before.  It's not a big
deal either way.

-Brian
