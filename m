From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net: rtnetlink: ignore NETDEV_PRE_TYPE_CHANGE in rtnetlink_event()
Date: Fri, 19 Mar 2010 15:56:10 +0100
Message-ID: <4BA3908A.1070008@trash.net>
References: <4BA38D50.4090909@trash.net> <20100319144707.GD2811@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39523 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668Ab0CSO4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 10:56:12 -0400
In-Reply-To: <20100319144707.GD2811@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko wrote:
> Fri, Mar 19, 2010 at 03:42:24PM CET, kaber@trash.net wrote:
>   
>
>   
>> Ignore the new NETDEV_PRE_TYPE_CHANGE event in rtnetlink_event() since
>> there have been no changes userspace needs to be notified of.
>>
>> Also add a comment to the netdev notifier event definitions to remind
>> people to update the exclusion list when adding new event types.
>
> Hmm, didn't have a clue this is needed. Anyway, original
> "NETDEV_BONDING_OLDTYPE" and "NETDEV_BONDING_NEWTYPE" weren't here either.

Its not strictly needed, it just avoids sending events without new
information.


> Also you might want to add "NETDEV_POST_TYPE_CHANGE".

I left this out on purpose since userspace might be interested in the
type change.
