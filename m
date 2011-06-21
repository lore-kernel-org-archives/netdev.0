From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel] [PATCH net-next 4/5] xen: convert to 64 bit stats
 interface
Date: Tue, 21 Jun 2011 15:57:22 -0700 (PDT)
Message-ID: <20110621.155722.1748866119828892714.davem@davemloft.net>
References: <1308665154.6920.46.camel@zakaz.uk.xensource.com>
	<20110621083531.00442d7f@nehalam.ftrdhcpuser.net>
	<1308670728.6920.86.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, Jeremy.Fitzhardinge@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xensource.com
To: Ian.Campbell@eu.citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756879Ab1FUW53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 18:57:29 -0400
In-Reply-To: <1308670728.6920.86.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Date: Tue, 21 Jun 2011 16:38:48 +0100

> On Tue, 2011-06-21 at 16:35 +0100, Stephen Hemminger wrote:
>> Convert xen driver to 64 bit statistics interface.
>> Use stats_sync to ensure that 64 bit update is read atomically on 32 bit platform.
>> Put hot statistics into per-cpu table.
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>> 
>> ---
>> v2 - add stats_sync and per-cpu
>> v2.1 - keep rx_errors on checksum error
> 
> Thanks. Looks good to me from the Xen side.
> 
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied.
