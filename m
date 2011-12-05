From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: [net-next 1/6] e1000e: Avoid wrong check on TX hang
Date: Mon, 05 Dec 2011 16:18:46 +0800
Message-ID: <4EDC7E66.8070404@linux.vnet.ibm.com>
References: <1322912671-6903-1-git-send-email-jeffrey.t.kirsher@intel.com> <1322912671-6903-2-git-send-email-jeffrey.t.kirsher@intel.com> <20111203.222659.277419094309941060.davem@davemloft.net> <1322983717.24828.8.camel@jtkirshe-mobl> <4EDC18D3.4060900@linux.vnet.ibm.com> <1323066318.24828.14.camel@jtkirshe-mobl> <4EDC6F76.2090504@linux.vnet.ibm.com> <1323072138.24828.32.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Flavio Leitner <fbl@redhat.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:57187 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353Ab1LEIS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 03:18:57 -0500
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wangyun@linux.vnet.ibm.com>;
	Mon, 5 Dec 2011 13:48:54 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB58Inmt1949792
	for <netdev@vger.kernel.org>; Mon, 5 Dec 2011 13:48:50 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB58Injm005639
	for <netdev@vger.kernel.org>; Mon, 5 Dec 2011 13:48:49 +0530
In-Reply-To: <1323072138.24828.32.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2011 04:02 PM, Jeff Kirsher wrote:

> On Sun, 2011-12-04 at 23:15 -0800, Michael Wang wrote:
>> On 12/05/2011 02:25 PM, Jeff Kirsher wrote:
>>
>>> On Sun, 2011-12-04 at 17:05 -0800, Michael Wang wrote:
>>>> On 12/04/2011 03:28 PM, Jeff Kirsher wrote:
>>>>
>>>>> On Sat, 2011-12-03 at 19:26 -0800, David Miller wrote:
>>>>>> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>>>>> Date: Sat,  3 Dec 2011 03:44:26 -0800
>>>>>>
>>>>>>> +	if ((!adapter->tx_hang_recheck) &&
>>>>>>
>>>>>> Excessive parenthesis, please remove.
>>>>>>
>>>>>>> +		adapter->tx_hang_recheck = 1;
>>>>>>
>>>>>> This variable is a bool, set it to true or false.
>>>>>>
>>>>>>> +			adapter->tx_hang_recheck = 0;
>>>>>>
>>>>>> Likewise.
>>>>>>
>>>>>>> +	adapter->tx_hang_recheck = 0;
>>>>>>
>>>>>> Likewise.
>>>>>
>>>>> Michael/Flavio -
>>>>>
>>>>> To expedite this patch, I can make the changes that Dave is requesting
>>>>> and re-submit v2 of the patch, if that is ok with you.
>>>>>
>>>>
>>>> Hi, Jeff
>>>>
>>>> That's ok for me, I think it's good if you can work with Dave and make
>>>> out a final version for us, if you want my help, please mail me at any
>>>> time, I'm glad to work with you.
>>>>
>>>> Flavio:
>>>> What's your opinion?
>>>>
>>>> Thanks,
>>>> Michael Wang
>>>
>>> I have the patch read to push, so I will go ahead an push v2 out
>>> tonight.  Since I am making changes to your patch, I will be removing
>>> your signed-off-by (and Flavio's) and keep you as a CC: so that you can
>>> verify the changes I have made to resolve the issues that Dave saw.
>>>
>>
>> Hi, Jeff
>>
>> Is that means you have a better patch which different from ours, and you
>> will use your patch to instead of ours?
>>
>> Because David is just ask for some small change, I think your time zone
>> may be better to work with him, so I ask for your help.
>>
>> I was just confused that why our signed-off-by should be removed?
>>
>> Thanks,
>> Michael Wang
>>
>>> Cheers,
>>> Jeff
> 
> It is your patch (your original work) but since I have made changes to
> your patch, I (or anyone for that matter) should not assume that you as
> the owner would signed off on the changes that I have made based on
> feedback.  It would not be right for me to send out a patch with your
> signed-off-by which is different from what you originally submitted,
> without your ok.  Once I send out the v2 of the patch, please feel free
> to add your signed-off-by OR acked-by to the patch.
> 

Hi, Jeff

That make sense, I'm sorry but because I'm new to the community, and I
just want to make every thing clear so I can do better in the future.

> While I personally do not have a problem keeping you as the owner and
> your signed-off-by, I believe that takes in several assumptions which
> only you as the owner should speak for.  I am not trying to take
> ownership for stats purposes, I care less about the number of patches I
> create and own and would rather make sure that the original owners get
> the credit due for the work they did.
> 


I'm so sorry and I regret if I make you unhappy by some wrong word,
please forgive me.

> So with that, when I send out my next series of patches please feel free
> to ACK or Sign-off on the changes made.  I just wanted to make sure that
> we get these changes in soon (with out delay).
> 
> I can wait if you want to keep ownership of the patch, I just wanted to
> ensure that we get your patch included as soon as possible based on the
> problem it fixes.

Please help us to make the patch perfect, and I'm very glad if I can
have the opportunity to work with you.

Thanks & Best regards
Michael Wang
