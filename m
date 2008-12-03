From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH next 1/2]e1000: e1000_adapter->polling_netdev is useless
Date: Wed, 3 Dec 2008 15:59:49 -0800
Message-ID: <9929d2390812031559q740f16bfhc1626b5d955ad737@mail.gmail.com>
References: <49353915.4060002@cn.fujitsu.com>
	 <20081202.150623.70107608.davem@davemloft.net>
	 <49368245.5040804@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Emil Tantilov" <emil.s.tantilov@intel.com>
To: "Wang Chen" <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:62504 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754163AbYLCX7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 18:59:51 -0500
Received: by yx-out-2324.google.com with SMTP id 8so1594814yxm.1
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2008 15:59:49 -0800 (PST)
In-Reply-To: <49368245.5040804@cn.fujitsu.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 3, 2008 at 4:57 AM, Wang Chen <wangchen@cn.fujitsu.com> wrote:
> David Miller said the following on 2008-12-3 7:06:
>> From: Wang Chen <wangchen@cn.fujitsu.com>
>> Date: Tue, 02 Dec 2008 21:33:09 +0800
>>
>>> e1000_adapter->polling_netdev is not actually used after allocated.
>>> So, my question is that is it useless?
>>
>> It's probably a leftover from before we added support for
>> multiqueue NAPI.
>>
>> Intel folks can probably confirm.
>
> Commit bea3348eef27e6044b6161fd04c3152215f96411
> "[NET]: Make NAPI polling independent of struct net_device objects."
> made NAPI polling to be independent of net_device.
> So e1000_adapter->polling_netdev is no longer used.
> Kill it.
>
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
>  drivers/net/e1000/e1000.h      |    1 -
>  drivers/net/e1000/e1000_main.c |   27 +--------------------------
>  2 files changed, 1 insertions(+), 27 deletions(-)
>

Testing looks good.
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

-- 
Cheers,
Jeff
