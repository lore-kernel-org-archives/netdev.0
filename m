From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH] net: Fix locking bug in netif_set_xps_queue
Date: Fri, 22 Feb 2013 13:21:09 -0800
Message-ID: <5127E145.2070008@intel.com>
References: <20130222163806.7590.98066.stgit@ahduyck-cp1.jf.intel.com> <20130222.151442.333174353561165623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com,
	dan.carpenter@oracle.com, jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57898 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755813Ab3BVVVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2013 16:21:17 -0500
In-Reply-To: <20130222.151442.333174353561165623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/22/2013 12:14 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Fri, 22 Feb 2013 08:38:44 -0800
>
>> Smatch found a locking bug in netif_set_xps_queue in which we were not
>> releasing the lock in the case of an allocation failure.
>>
>> This change corrects that so that we release the xps_map_mutex before
>> returning -ENOMEM in the case of an allocation failure.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Applied and queue up for -stable, thanks Alex.

No patch is needed for -stable.  This was something I had introduced
into net-next when I moved the XPS logic into its own function.

Thanks,

Alex
