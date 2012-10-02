From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 1/1] ipv6: add support of equal cost
 multipath (ECMP)
Date: Tue, 02 Oct 2012 14:43:00 -0400 (EDT)
Message-ID: <20121002.144300.2008381378733752041.davem@davemloft.net>
References: <1349193767-3992-1-git-send-email-nicolas.dichtel@6wind.com>
	<1349193767-3992-2-git-send-email-nicolas.dichtel@6wind.com>
	<506B1104.7030908@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joe@perches.com, bernat@luffy.cx, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49869 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097Ab2JBSnC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 14:43:02 -0400
In-Reply-To: <506B1104.7030908@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 02 Oct 2012 18:06:28 +0200

> Le 02/10/2012 18:02, Nicolas Dichtel a =E9crit :
>> Each nexthop is added like a single route in the routing table. All
>> routes
>> that have the same metric/weight and destination but not the same
>> gateway
>> are considering as ECMP routes. They are linked together, through a
>> list called
>> rt6i_siblings.
>>
>> ECMP routes can be added in one shot, with RTA_MULTIPATH attribute o=
r
>> one after
>> the other (in both case, the flag NLM_F_EXCL should not be set).
>>
>> The patch is based on a previous work from
>> Luc Saillard <luc.saillard@6wind.com>.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> I forget to run checkpatch.pl, some lines are over 80 columns. I will
> fix it in the v7 with other comments (if any).

No rush as this is too late for this merge window anyways.
