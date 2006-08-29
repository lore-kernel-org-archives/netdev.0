From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 22/26] ixgb: Cache-align all TX components of the adapter
 struct.
Date: Tue, 29 Aug 2006 14:01:48 -0700
Message-ID: <44F4AB3C.3000205@intel.com>
References: <20060829164153.6872.1713.stgit@gitlost.site> <20060829164503.6872.93015.stgit@gitlost.site> <200608291933.56002.dada1@cosmosbay.com> <44F4AAC5.5030909@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	akpm@osdl.org, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63100 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S965418AbWH2VWC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 17:22:02 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44F4AAC5.5030909@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Eric Dumazet wrote:
>> On Tuesday 29 August 2006 18:45, Kok, Auke wrote:
>>>      /* TX */
>>> -    struct ixgb_desc_ring tx_ring;
>>> +    struct ixgb_desc_ring tx_ring ____cacheline_aligned;
>>>      unsigned long timeo_start;
>>
>> On UP, this would only enlarge the size of structure and might consume 
>> more cache lines...
>>
>>  I guess ____cacheline_aligned_in_smp is preferred here.
>>
>> (see include/linux/netdevice.h)
> 
> Agreed.

No objections. I can rework my tree if needed, but lets wait what else comes up 
first.

Auke
