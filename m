From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] xen-netback: count number required slots for an skb
 more carefully
Date: Wed, 04 Sep 2013 16:06:51 +0800
Message-ID: <5226EA1B.1030303@oracle.com>
References: <1378229390-12919-1-git-send-email-david.vrabel@citrix.com> <20130903215328.GA13465@zion.uk.xensource.com> <52269A37.7030600@oracle.com> <20130904060446.GA25227@u109add4315675089e695.ant.amazon.com> <5226D994.9000401@oracle.com> <20130904073857.GI14104@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Wilson <msw@linux.com>,
	David Vrabel <david.vrabel@citrix.com>,
	xen-devel@lists.xen.org,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	msw@amazon.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23034 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753377Ab3IDIHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 04:07:09 -0400
In-Reply-To: <20130904073857.GI14104@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-9-4 15:38, Wei Liu wrote:
> On Wed, Sep 04, 2013 at 02:56:20PM +0800, annie li wrote:
>> On 2013-9-4 14:04, Matt Wilson wrote:
>>> On Wed, Sep 04, 2013 at 10:25:59AM +0800, annie li wrote:
>>>> On 2013-9-4 5:53, Wei Liu wrote:
>>> [...]
>>>>> Matt, do you fancy sending the final version? IIRC the commit message
>>>>> needs to be re-written. I personally still prefer Matt's solution as
>>>>> it a) make efficient use of the ring, b) uses ring pointers to
>>>>> calculate slots which is most accurate, c) removes the dependence on
>>>>> MAX_SKB_FRAGS in guest RX path.
>>>>>
>>>>> Anyway, we should get this fixed ASAP.
>>>> Totally agree. This issue is easy to be reproduced with large MTU.
>>>> It is better to upstream the fix soon in case others hit it and
>>>> waste time to fix it.
>>> I'd like to go with Xi's proposed patch that I posed earlier. The main
>>> thing that's kept me from sending a final version is lack of time to
>>> retest against a newer kernel.
>>>
>>> Could someone help out with that? I probably can't get to it until the
>>> end of the week.
>> I can rebase it. Since wei's NAPI &1:1 model patch went into
>> net-next already, it should not be able to applied directly.
>>
> I think this one should go to net then queue up for stable, not
> net-next.
If so, that would be easier. It is almost end of the day here, and I do 
not have enough time to test it until tomorrow. Please go ahead with it 
if you have time.

Thanks
Annie
> Wei.
>
>> Thanks
>> Annie
>>> Sorry for the delay. :-(
>>>
>>> --msw
