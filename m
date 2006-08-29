From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 22/26] ixgb: Cache-align all TX components of the adapter
 struct.
Date: Tue, 29 Aug 2006 16:59:49 -0400
Message-ID: <44F4AAC5.5030909@pobox.com>
References: <20060829164153.6872.1713.stgit@gitlost.site> <20060829164503.6872.93015.stgit@gitlost.site> <200608291933.56002.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	akpm@osdl.org, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:11149 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965358AbWH2U7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 16:59:54 -0400
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <200608291933.56002.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> On Tuesday 29 August 2006 18:45, Kok, Auke wrote:
>>  	/* TX */
>> -	struct ixgb_desc_ring tx_ring;
>> +	struct ixgb_desc_ring tx_ring ____cacheline_aligned;
>>  	unsigned long timeo_start;
> 
> On UP, this would only enlarge the size of structure and might consume more 
> cache lines...
> 
>  I guess ____cacheline_aligned_in_smp is preferred here.
> 
> (see include/linux/netdevice.h)

Agreed.

	Jeff



