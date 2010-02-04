From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [net-next-2.6 PATCH v2 1/3] ethtool: Introduce n-tuple filter
 programming support
Date: Thu, 04 Feb 2010 17:34:47 -0500
Message-ID: <4B6B4B87.6020500@garzik.org>
References: <20100204074811.16559.84676.stgit@localhost.localdomain> <20100204.091854.24215476.davem@davemloft.net>  <Pine.WNT.4.64.1002041325210.27432@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f189.google.com ([209.85.211.189]:54084 "EHLO
	mail-yw0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755207Ab0BDWlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 17:41:24 -0500
Received: by ywh27 with SMTP id 27so2799603ywh.1
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2010 14:41:22 -0800 (PST)
In-Reply-To: <Pine.WNT.4.64.1002041325210.27432@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/2010 04:26 PM, Waskiewicz Jr, Peter P wrote:
> On Thu, 4 Feb 2010, David Miller wrote:
>
>> From: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>> Date: Wed, 03 Feb 2010 23:48:13 -0800
>>
>>> +#define ETHTOOL_RXNTUPLE_ACTION_DROP -1
>>> +	struct list_head list;
>>> +};
>>
>> You can't do this.
>>
>> You put the list_head here in the kernel header, which BTW can
>> be used by userspace too, and then you elide it in the
>> ethtool utility copy of the header.
>>
>> Use an encapsulator if you must inside of the kernel, but keep the
>> userspace visible data structure clean of RCU and list_head
>> kernel datastructures.
>
> Ok.  I'll respin this asap.  Thanks for the quick review Dave.

Great.  I'll look for the updated userspace patch, too, and put it into 
the ethtool-2.6.34 pile (ie. ethtool-net-next).

	Jeff




