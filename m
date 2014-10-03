From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] fm10k: Add CONFIG_FM10K_VXLAN configuration option
Date: Fri, 03 Oct 2014 15:01:00 -0700 (PDT)
Message-ID: <20141003.150100.2093419669359736448.davem@davemloft.net>
References: <1412370352-17680-1-git-send-email-azhou@nicira.com>
	<542F17B7.80706@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: azhou@nicira.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60032 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755232AbaJCV6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 17:58:54 -0400
In-Reply-To: <542F17B7.80706@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 03 Oct 2014 14:40:07 -0700

> On 10/03/2014 02:05 PM, Andy Zhou wrote:
>> Compiling with CONFIG_FM10K=y and VXLAN=m resulting in linking error:
>> 
>>    drivers/built-in.o: In function `fm10k_open':
>>    (.text+0x1f9d7a): undefined reference to `vxlan_get_rx_port'
>>    make: *** [vmlinux] Error 1
>> 
>> The fix follows the same strategy as I40E.
>> 
>> Signed-off-by: Andy Zhou <azhou@nicira.com>
>> ---
>>  drivers/net/ethernet/intel/Kconfig              | 11 +++++++++++
>>  drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |  6 +++---
>>  2 files changed, 14 insertions(+), 3 deletions(-)
> 
> Looks good to me.  Thanks for resolving this.
> 
> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>

I expect this will go via Jeff Kirsher, CC:'d.
