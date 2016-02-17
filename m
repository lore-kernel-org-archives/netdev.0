From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 6/8] net: ixgbe: add minimal parser details
 for ixgbe
Date: Wed, 17 Feb 2016 07:14:11 -0800
Message-ID: <56C48E43.7050207@gmail.com>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>	<20160217051828.17139.51653.stgit@john-Precision-Tower-5810>	<56C4541A.5070508@mojatatu.com> <20160217.100906.816402468592090571.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, amir@vadai.me, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>, jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34169 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605AbcBQPOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 10:14:24 -0500
Received: by mail-pa0-f52.google.com with SMTP id fy10so12782351pac.1
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 07:14:23 -0800 (PST)
In-Reply-To: <20160217.100906.816402468592090571.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-17 07:09 AM, David Miller wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> Date: Wed, 17 Feb 2016 06:06:02 -0500
> 
>> On 16-02-17 12:18 AM, John Fastabend wrote:
>>> This adds an ixgbe data structure that is used to determine what
>>> headers:fields can be matched and in what order they are supported.
>>>
>>> For hardware devices this can be a bit tricky because typically
>>> only pre-programmed (firmware, ucode, rtl) parse graphs will be
>>> supported and we don't yet have an interface to change these from
>>> the OS. So its sort of a you get whatever your friendly vendor
>>> provides affair at the moment.
>>>
>>> In the future we can add the get routines and set routines to
>>> update this data structure. One interesting thing to note here
>>> is the data structure here identifies ethernet, ip, and tcp
>>> fields without having to hardcode them as enumerations or use
>>> other identifiers.
>>>
>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>
>>
>> should __u32 be u32? Also at some points you seem to interchangeably
>> use unsigned int vs u32. I think most of unsigned ints should be u32.
> 
> Anything only kernel visible should be 'u32', whereas if the object is
> exported via a uapi header file it should be '__u32'.
> 

yep, it looks like you may have applied the series so I'll push a
fix for this and another to align the structs a bit better in cls_u32 as
well per Jamals feedback.

Thanks.
