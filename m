From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv8 net-next 2/4] sunvnet: make transmit path zero-copy
 in the kernel
Date: Mon, 29 Sep 2014 17:02:33 -0400
Message-ID: <5429C8E9.2070607@oracle.com>
References: <5429B8E2.40204@oracle.com>	<20140929.162950.1960056644564225055.davem@davemloft.net>	<5429C498.1000705@oracle.com> <20140929.165440.1575595209745066192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	raghuram.kothakota@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46407 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbaI2VCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 17:02:00 -0400
In-Reply-To: <20140929.165440.1575595209745066192.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/29/2014 04:54 PM, David Miller wrote:
> From: David L Stevens <david.stevens@oracle.com>

>> For example, I could leave the "normal" path like this and just start/mod
>> a timer to do it after 1 sec if we haven't done it through start_xmit. Do
>> you think that's sufficiently short?
> 
> To be honest I'm not %100 sure.

Since it won't actually fire when the network is loaded, maybe a
shorter timer won't hurt. I'll try it out.

						+-DLS
