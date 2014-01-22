From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] net: sctp: Fix a_rwnd/rwnd management to reflect real
 state of the receiver's buffer
Date: Tue, 21 Jan 2014 19:08:20 -0500
Message-ID: <52DF0BF4.8080905@gmail.com>
References: <52D8D544.5050501@nsn.com> <20140121.143620.1777441472756091252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, alexander.sverdlin@nsn.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	matija.glavinic-pecotic.ext@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:54182 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbaAVAIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 19:08:23 -0500
In-Reply-To: <20140121.143620.1777441472756091252.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/2014 05:36 PM, David Miller wrote:
> From: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
> Date: Fri, 17 Jan 2014 08:01:24 +0100
> 
>> Implementation of (a)rwnd calculation might lead to severe performance issues
>> and associations completely stalling. These problems are described and solution
>> is proposed which improves lksctp's robustness in congestion state.
> 
> It would be fantastic if an SCTP expert would review this patch, it's
> been rotting in patchwork for 4 days.
> 

Apologies.  It's been on my to do list.

-vlad
