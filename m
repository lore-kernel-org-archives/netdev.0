From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in non-interrupt
 context.
Date: Wed, 01 Oct 2014 15:55:35 -0400
Message-ID: <542C5C37.1040409@oracle.com>
References: <20141001185604.GG17706@oracle.com> <20141001.155009.2277009117294992988.davem@davemloft.net>
Reply-To: sowmini.varadhan@oracle.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43353 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbaJATzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 15:55:39 -0400
In-Reply-To: <20141001.155009.2277009117294992988.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/2014 03:50 PM, David Miller wrote:

>>
>>     A BH Rx handler is a simpler way to  avoid the weaknesses of processing
>>     packets in LDC interrupt context, and also provides Rx load-spreading
>>     across multiple CPUs.
>
> I think you want to re-evaluate this considering napi_gro_receive() which
> is what you should really be calling in a NAPI driver.


Sorry I dont follow the suggestion.

If I make this a NAPI driver that uses napi_gro_receive, I would
still have to deal with a budget, right?

--Sowmini
