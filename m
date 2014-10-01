From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] sunvnet: vnet_start_xmit() must hold a
 refcnt on port.
Date: Wed, 01 Oct 2014 15:52:10 -0400 (EDT)
Message-ID: <20141001.155210.882272719949254470.davem@davemloft.net>
References: <542C50A4.30304@oracle.com>
	<20141001192325.GK17706@oracle.com>
	<542C56A5.4070805@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, raghuram.kothakota@oracle.com,
	netdev@vger.kernel.org
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806AbaJATwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 15:52:13 -0400
In-Reply-To: <542C56A5.4070805@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Wed, 01 Oct 2014 15:31:49 -0400

> 
> 
> On 10/01/2014 03:23 PM, Sowmini Varadhan wrote:
>> On (10/01/14 15:06), David L Stevens wrote:
>>>
>>> This "vp->switch_port" addition doesn't appear to be related to the port refcnt
>>> change, and doesn't allow for multiple switch ports.
>> 
>> The switch_port is the connection to Dom0. Do you envision us having more than
>> one switch_port? How?
> 
> While Dom0 might only create one port with the "switch" flag, the flag just means
> "I can reach anybody" and is not inherently unique. I don't think an attached
> VM should assume there is always only one; it prevents multipath load balancing
> kinds of things in the future.
> 
> Also, there is the broader point that this sort of change should be a separate patch.
> It isn't required for fixing the dangling reference -- it is an independent change.

Multiple switch ports are absolutely allowed by the protocol spec and can
provide the suggested facilities David mentioned, don't prevent them from
being used.
