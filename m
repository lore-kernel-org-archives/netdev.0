From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Tue, 01 Apr 2008 13:52:49 +0200
Message-ID: <47F22211.5080100@trash.net>
References: <47EAAFEC.6000805@trash.net>	<20080331123311.64e4ca37@extreme>	 <47F13E43.2040404@trash.net>	 <20080331.130757.199769025.davem@davemloft.net>	 <47F1467F.2080407@trash.net> <1207000143.4424.167.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59260 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958AbYDALwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 07:52:55 -0400
In-Reply-To: <1207000143.4424.167.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Mon, 2008-31-03 at 22:15 +0200, Patrick McHardy wrote:
> 
>> I'll cook something up based on my and Stephen's patches.
> 
> Nice - now we can move all the filtering off iproute2;->
> 
> My view is that the nature of most stuff to filter on _events_ will
> depend on something along a "whodunnit" field. Route messages have a
> rudimentary form of such a field (the "protocol" field on the quagga
> patch Stephen posted for example uses it). It would be really nice to be
> able to generate such a field on all events to emit say the processid of
> the process which caused the event. Ive been thinking of adding a
> permanent field like that on the actions/filters. What are peoples
> thoughts on that?


Isn't that what nlmsg_pid already contains?
