From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Wed, 11 Apr 2007 18:52:33 +0200
Message-ID: <461D1251.8050709@trash.net>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>	 <20070409.114402.45491411.davem@davemloft.net>	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>  <461A9DF1.8080904@trash.net>	 <1176150557.8459.47.camel@johannes.berg>  <461AD517.2000906@trash.net>	 <1176239819.10381.10.camel@johannes.berg>  <461D09AD.9060603@trash.net> <1176309793.3826.7.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	dim@openvz.org, netdev@vger.kernel.org, jgarzik@pobox.com,
	containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	shemminger@linux-foundation.org, greearb@candelatech.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57096 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317AbXDKQwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 12:52:43 -0400
In-Reply-To: <1176309793.3826.7.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Wed, 2007-04-11 at 18:15 +0200, Patrick McHardy wrote:
> 
>> But you have a valid point, if we want to use
>>this for things like bonding or VLAN that aren't actually address
>>families, we should consider introducing "rtnetlink families" to
>>avoid adding AF_BONDING, AF_8021Q etc.
> 
> 
> True.
> 
> But this still doesn't help wireless which doesn't have either an
> rtnetlink family nor an address family since it uses generic netlink
> exclusively.


I'm not sure I'm following. I was under the impression that the
conclusion of yesterdays discussion was that its probably not
worth using rtnetlink for wireless so it will continue to use
generic netlink exclusively, but even if that is wrong, nothing
would prevent adding a "rtnetlink family" for wireless as well.
The idea of introducing "rtnetlink families" is exactly to avoid
adding real address families for things that don't have one to
avoid possible conflicts with IANA allocated numbers.

