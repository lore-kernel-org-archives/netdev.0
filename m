From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/9] mlxsw: implement port mirroring offload
Date: Thu, 21 Jul 2016 11:33:41 +0200
Message-ID: <20160721093341.GB2171@nanopsycho.orion>
References: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
 <83af7d8a-5f9c-aa3e-53cd-641cb175f66d@mojatatu.com>
 <20160721090706.GA2171@nanopsycho.orion>
 <468bb089-e263-47bb-eaf8-1a65b2575092@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
	eladr@mellanox.com, idosch@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35410 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbcGUJdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 05:33:44 -0400
Received: by mail-wm0-f47.google.com with SMTP id f65so15551850wmi.0
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 02:33:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <468bb089-e263-47bb-eaf8-1a65b2575092@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jul 21, 2016 at 11:24:10AM CEST, jhs@mojatatu.com wrote:
>On 16-07-21 05:07 AM, Jiri Pirko wrote:
>>Thu, Jul 21, 2016 at 11:00:33AM CEST, jhs@mojatatu.com wrote:
>>>On 16-07-21 04:19 AM, Jiri Pirko wrote:
>>>>From: Jiri Pirko <jiri@mellanox.com>
>>>>
>[..]
>>
>>>infrastructure. If answer is yes, thencould we have used
>>>a classifier like u32 here?
>>>i.e something like:
>>>tc filter add dev eth25 xxxx protocol all \
>>>u32 match u32 0 0 \
>>>action mirred ...
>>
>>That could be used. But I believe it is nicer to have explicit match-all
>>classifier for this case. That puts nice limit to what could be matched.
>>
>
>Iam indifferent. If you are planning to use u32 for ACL then it would
>make sense to support span + ACL with the same classifier.
>
>>Could you point to that? checkpatch.pl does not say anything and I also
>>don't see anything.
>>
>
>scripts/Lindent (but you need to be a little careful with it)
>Generally the coding style guide in Documentation is sufficient.

As I said, I don't see any issue. Could you please reply to that
specific patch on a place where you see the issue?

Thanks.
