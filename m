From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH v2 0/2] l2 hardware accelerated macvlans
Date: Tue, 05 Nov 2013 07:17:21 -0800
Message-ID: <52790C01.3070107@intel.com>
References: <20131104185717.11802.69282.stgit@jf-dev1-dcblab> <5279051B.6000406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11851 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750807Ab3KEPRn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 10:17:43 -0500
In-Reply-To: <5279051B.6000406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/5/2013 6:47 AM, Vlad Yasevich wrote:
> Hi John
>

[...]

>> series. It would be best (I think) to use the software
>> path for macvlan to macvlan traffic and save the PCIe
>> bus. Also this only allows for layer 2 mac forwarding
>> where some hardware supports more interesting forwarding
>> capabilities. Integrating with OVS may be useful here.
>
> This seems to be saying that for macvlan-macvlan
> case, you still prefere to do software based forwarding, but
> patch 1 in the series seem to always attempt to do hardware
> offloaded forwarding regardless of traffic and macvlan type.
> Can you clarify.
>
> Thanks
> -vlad
>

This series always attempts to do hardware offload even in the
macvlan-macvlan case as you note. I'm suggesting a further
optimization might be to use the software based forwarding in
this case. My plan is to investigate this after I get the initial
series completed.

.John
