From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC PATCH] net: Add support for device specific address syncing
Date: Fri, 16 May 2014 15:24:27 -0700
Message-ID: <5376901B.7040700@intel.com>
References: <53765D5D.9040207@intel.com>	<20140516.150115.1106293449904617860.davem@davemloft.net>	<53766D3E.4080904@intel.com> <20140516.164728.2297526772904518777.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jpirko@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:42546 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752758AbaEPWY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 18:24:28 -0400
In-Reply-To: <20140516.164728.2297526772904518777.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/2014 01:47 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Fri, 16 May 2014 12:55:42 -0700
> 
>> I can understand going into promisc on a sync failure, but why would you
>> do it on an unsync failure, or are you saying that we would be clearing
>> the flag in unsync?
> 
> We should clear the promisc flag on unsync if the limitations are no
> longer exceeded.
> 
>> In general I intended for this to be called in set_rx_mode so if
>> __dev_uc_sync returns an error indicating insufficient resources we have
>> to force IFF_PROMISC on because adding a new address failed.  We could
>> also do the same thing for __dev_mc_sync and IFF_ALLMULTI.
> 
> Right.
> 

Okay, I think that all works.  I'll probably resubmit it next week after
it has gone though a bit more testing.

Thanks,

Alex
