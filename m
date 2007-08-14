From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/4] Add ETHTOOL_[GS]FLAGS sub-ioctls
Date: Tue, 14 Aug 2007 13:38:58 -0700
Message-ID: <46C212E2.3020401@intel.com>
References: <46BCD47C.9060408@candelatech.com>	<20070810.151039.31642625.davem@davemloft.net>	<46BCE942.1030107@candelatech.com> <20070810.154601.98709831.davem@davemloft.net> <46BCF1AF.3080000@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, greearb@candelatech.com,
	jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32410 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755594AbXHNUj2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 16:39:28 -0400
In-Reply-To: <46BCF1AF.3080000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> David Miller wrote:
>> From: Ben Greear <greearb@candelatech.com>
>> Date: Fri, 10 Aug 2007 15:40:02 -0700
>>
>>
>>> For GSO on output, is there a generic fallback for any driver that
>>> does not specifically implement GSO?
>>
>> Absolutely, in fact that's mainly what it's there for.
>>
>> I don't think there is any issue.  The knob is there via
>> ethtool for people who really want to disable it.
> 
> Just to be paranoid (who me?) we are then at a point where what happened 
> a couple months ago with forwarding between 10G and IPoIB won't happen 
> again - where things failed because a 10G NIC had LRO enabled by default?

we still have the NETIF_F_LRO flag which Jeff will keep around. Perhaps the 
IPoIB code can force this to _off_ when setting it up? (or at least warn about it).

Auke
