From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPROUTE 02/05]: Introduce tc_calc_xmitsize and use where appropriate
Date: Mon, 15 Jan 2007 16:07:27 +0100
Message-ID: <45AB98AF.5030401@trash.net>
References: <20070115123518.GA3124@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60674 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbXAOPHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 10:07:30 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20070115123518.GA3124@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On 10-01-2007 11:01, Patrick McHardy wrote:
> 
>>[IPROUTE]: Introduce tc_calc_xmitsize and use where appropriate
>>
>>Add tc_calc_xmitsize() as complement to tc_calc_xmittime(), which calculates
>>the size that can be transmitted at a given rate during a given time.
>>
>>Replace all expressions of the form "size = rate*tc_core_tick2usec(time))/1000000"
>>by tc_calc_xmitsize() calls.
>>
>>Signed-off-by: Patrick McHardy <kaber@trash.net>
>>
>>---
> 
> ...
> 
>>+unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks)
>>+{
>>+	return ((double)rate*tc_core_tick2usec(ticks))/1000000;
>>+}
>>+
> 
> 
> Actually, besides of replacing the expression, this function
> changes its type to unsigned also.


It doesn't change it, all expressions I replaced were directly
assigned to an unsigned int variable.

