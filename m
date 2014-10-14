From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] fm10k: Add skb->xmit_more support
Date: Tue, 14 Oct 2014 13:09:33 -0400 (EDT)
Message-ID: <20141014.130933.1824142900652327447.davem@davemloft.net>
References: <20141010213013.20973.19209.stgit@ahduyck-workstation.home>
	<1413026083.2427.59.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, matthew.vick@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbaJNRJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 13:09:36 -0400
In-Reply-To: <1413026083.2427.59.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 11 Oct 2014 04:14:43 -0700

> On Fri, 2014-10-10 at 14:30 -0700, alexander.duyck@gmail.com wrote:
>> From: Alexander Duyck <alexander.h.duyck@redhat.com>
>> 
>> This change adds support for skb->xmit_more based on the changes that
>> were
>> made to igb to support the feature.  The main changes are moving up
>> the
>> check for maybe_stop_tx so that we can check netif_xmit_stopped to
>> determine
>> if we must write the tail because we can add no further buffers.
>> 
>> Acked-by: Matthew Vick <matthew.vick@intel.com>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>> ---
>> 
>> v2: Minor fix to patch description for typo.
>> 
>>  drivers/net/ethernet/intel/fm10k/fm10k_main.c |   65
>> +++++++++++++------------
>>  1 file changed, 34 insertions(+), 31 deletions(-)
> 
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Its like you never left Intel Alex... :-)
> Dave, please pull this.

Applied, thanks everyone.
