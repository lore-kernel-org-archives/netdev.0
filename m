From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 05/10] igb: Update igb to use a path similar to ixgbe
 to determine when to stop Tx
Date: Fri, 08 Feb 2013 12:19:29 -0800
Message-ID: <51155DD1.8030500@intel.com>
References: <1360319958-10497-6-git-send-email-jeffrey.t.kirsher@intel.com> <1360326369.28557.95.camel@edumazet-glaptop> <511531AE.8030807@intel.com> <20130208.141854.2122874496462368419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6742 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964813Ab3BHUTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2013 15:19:31 -0500
In-Reply-To: <20130208.141854.2122874496462368419.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/8/2013 11:18 AM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Fri, 08 Feb 2013 09:11:10 -0800
>
>> For igb the IGB_MAX_DATA_PER_TXD is 32K as well.  So if I am not
>> mistaken we should be fine.  The only time we risk exceeding that is
>> if we have 64K page size.  It sounds like we may need to work in the
>> ixgbe driver though since I believe the limit for it is only 16K per
>> descriptor.
>>
>> I will also submit an update for this patch that replaces PAGE_SIZE
>> with NETDEV_FRAG_PAGE_MAX_SIZE in order to keep the two in sync.
> I therefore expect a respin of this series from Jeff once the
> update of this patch is resolved.
>
> Thanks.

I will work with Jeff to get that resolved.  Also I will be submitting 
one patch directly it looks like since NETDEV_FRAG_PAGE_MAX_SIZE turns 
out to be defined in skbuff.c so I will need to pull it into skbuff.h 
most likely.

Thanks,

Alex
