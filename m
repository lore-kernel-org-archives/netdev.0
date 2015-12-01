From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Stable interface index option
Date: Tue, 01 Dec 2015 14:27:49 -0500 (EST)
Message-ID: <20151201.142749.1921315575696738796.davem@davemloft.net>
References: <20151201153441.GA17843@oracle.com>
	<20151201155052.GA14984@principal.rfc2324.org>
	<1448985743.3387258.454809153.36540D70@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: max@rfc2324.org, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbbLAT1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 14:27:50 -0500
In-Reply-To: <1448985743.3387258.454809153.36540D70@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 01 Dec 2015 17:02:23 +0100

> On Tue, Dec 1, 2015, at 16:50, Maximilian Wilhelm wrote:
>> > I'm not sure I understand how this would work- are we going to 
>> > pin down the ifindex for some subset of interfaces?
>> 
>> I'm not sure what your idea is, but I guess we might mean the same
>> thing:
>> 
>> What I have in mind is that the user can supply a list of (ifname ->
>> ifindex) entries via a sysfs/procfs interface and if such a list is
>> present, the kernel will search the list for every ifname which is
>> registered and check if there is an entry. If there is, the ifindex
>> for this entry is used. If there is no entry found for the given
>> ifname, the usual algorithm is used (therefore inherently providing
>> backward compatibility).
> 
> Sorry to ask because I don't like this feature at all. There was a lot
> of work on stable interface names. Why do you need stable ifindexes,
> which were never meant to be stable for a longer amount of time?

Because all the remote SNMP tools work with interface indexes, not names.
