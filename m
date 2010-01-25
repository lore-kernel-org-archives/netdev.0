From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH] extend RTM_GETNEIGH to allow getting more precise
 information
Date: Mon, 25 Jan 2010 14:51:54 +0100
Message-ID: <4B5DA1FA.4030905@trash.net>
References: <201001151842.59813.cratiu@ixiacom.com> <20100123.021233.122638456.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: cratiu@ixiacom.com, netdev@vger.kernel.org,
	ixlk-cr@farscape.ixiacom.com, pchakrabarti@ixiacom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43875 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429Ab0AYNv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 08:51:59 -0500
In-Reply-To: <20100123.021233.122638456.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Cosmin Ratiu <cratiu@ixiacom.com>
> Date: Fri, 15 Jan 2010 18:42:59 +0200
> 
>> Please have a look at this patch which tries to solve a problem we 
>> encountered.
>>
>> The background is that RTM_GETNEIGH netlink message is used to get a complete 
>> dump of a neighbor table. Sometimes, that's too much (especially when you have 
>> a lot of neighbors). This patch allows one to specify the IPv4/6 address of a 
>> neighbor and the device index through which it is accessible in order to 
>> obtain only that entry.
>>
>> If you have other suggestions on how to accomplish this task, please let us 
>> know.
> 
> Please add a netlink attribute to specify lookup keys.
> 
> Adding specifiers to the end of the existing request message
> error prone and creates trouble in the future if someone gets
> the idea to add something more.

It should also use a seperate callback for looking up individual
entries instead of the NLM_F_DUMP callback.
