From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH] net: Export __netdev_pick_tx so that it can be used in
 modules
Date: Sun, 13 Jan 2013 09:27:16 -0800
Message-ID: <50F2EE74.6080207@intel.com>
References: <20130111183842.6152.34578.stgit@ahduyck-cp1.jf.intel.com> <50F061B9.4060703@intel.com> <50F0902B.5060500@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46915 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754782Ab3AMR21 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jan 2013 12:28:27 -0500
In-Reply-To: <50F0902B.5060500@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/11/2013 2:20 PM, Alexander Duyck wrote:
> On 01/11/2013 11:02 AM, John Fastabend wrote:
>> On 1/11/2013 10:38 AM, Alexander Duyck wrote:
>>> When testing with FCoE enabled we discovered that I had not exported
>>> __netdev_pick_tx.  As a result ixgbe doesn't build with the RFC patches
>>> applied because ixgbe_select_queue was calling the function.  This change
>>> corrects that build issue by correctly exporting __netdev_pick_tx so it
>>> can be used by modules.
>>>
>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>>> ---
>>
>> Hi Alex,
>>
>> If we get XPS to play nicely with the traffic class schemes we
>> can just remove select_queue completely.
>>
>> I'll take a look tomorrow.
>>
>> Thanks,
>> John
>
> Hi John,
>
> It would be great if we could drop it entirely.
>
> I just to make sure we are on the same page.  What you are saying is
> that we could do that in addition to this patch correct?  I'm pretty

Yes correct an additional patch on top of your work. This patch series
just got me thinking about it again.

.John
