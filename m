From: Vipul Pandya <vipul@chelsio.com>
Subject: Re: [PATCH net-next] cxgb4: Allow for backward compatibility with
 new VPD scheme.
Date: Mon, 11 Mar 2013 17:19:07 +0530
Message-ID: <513DC4B3.3050905@chelsio.com>
References: <513D70F7.4090708@chelsio.com> <20130311.023009.1276623167785151916.davem@davemloft.net> <513D7F58.1080807@chelsio.com> <20130311.074136.1262065455365949917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Divy Le Ray <divy@chelsio.com>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Abhishek Agrawal <abhishek@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:32223 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753886Ab3CKLtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 07:49:13 -0400
In-Reply-To: <20130311.074136.1262065455365949917.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11-03-2013 17:11, David Miller wrote:
> From: Vipul Pandya <vipul@chelsio.com>
> Date: Mon, 11 Mar 2013 12:23:12 +0530
> 
>>
>>
>> On 11-03-2013 12:00, David Miller wrote:
>>> From: Vipul Pandya <vipul@chelsio.com>
>>> Date: Mon, 11 Mar 2013 11:21:51 +0530
>>>
>>>>
>>>>
>>>> On 08-03-2013 23:14, David Miller wrote:
>>>>> From: Vipul Pandya <vipul@chelsio.com>
>>>>> Date: Fri,  8 Mar 2013 19:05:29 +0530
>>>>>
>>>>>> From: Santosh Rastapur <santosh@chelsio.com>
>>>>>>
>>>>>> New scheme calls for 3rd party VPD at offset 0x0 and Chelsio VPD at offset
>>>>>> 0x400 of the function.  If no 3rd party VPD is present, then a copy of
>>>>>> Chelsio's VPD will be at offset 0x0 to keep in line with PCI spec which
>>>>>> requires the VPD to be present at offset 0x0.
>>>>>>
>>>>>> Signed-off-by: Santosh Rastapur <santosh@chelsio.com>
>>>>>> Signed-off-by: Vipul Pandya <vipul@chelsio.com>
>>>>>
>>>>> Isn't this a fix which is better targetted at 'net' than 'net-next'?
>>>>>
>>>>
>>>> We have very soon new patch series coming up for net-next. This patch
>>>> requires for that patch series to work correctly. So, we would like to
>>>> get this merge in net-next tree.
>>>
>>> But you can achieve that by asking me to apply this to 'net' and then
>>> when the patch series that depends upon it is posted, you tell me about
>>> this dependency.
>>>
>> Ok. I was not aware of this. However there can be a merge conflict at
>> the time of merging 'net' and 'net-next' tree if this patch gets applied
>> in 'net' tree and our new patch series gets applied in 'net-next'. To
>> avoid it we recommended the same. The merge conflict wont be a major and
>> if it is alright to resolve it we can apply this patch to 'net' tree.
> 
> That's why you tell me to first pull net into net-next, and you send
> me a patch set for net-next which assumes the fix from 'net' is
> already applied.
> 

Ok, I will inform you about the patch dependency on 'net' tree when I
post the patch series targeted for 'net-next'. Please consider applying
this patch to net tree.

Thanks,
Vipul
