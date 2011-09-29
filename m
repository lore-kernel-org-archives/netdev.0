From: Rongqing Li <rongqing.li@windriver.com>
Subject: Re: [PATCH] Ipv6: Delete rcu_read_lock
Date: Thu, 29 Sep 2011 17:10:31 +0800
Message-ID: <4E843607.6010306@windriver.com>
References: <1317282414-13368-1-git-send-email-rongqing.li@windriver.com>	<CAAM7YAnE4w4y6YWWxk0QGOX8Y6AZQHHQBuVMoRuSm=GtALAx=Q@mail.gmail.com>	<4E842B93.3010203@windriver.com> <CAAM7YAmwXyORpFWhthX4iSEkBp7OANnZ8tHruEyN62Z3mnOdLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Yan, Zheng " <yanzheng@21cn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:65085 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754959Ab1I2JK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 05:10:29 -0400
Received: from ALA-HCA.corp.ad.wrs.com (ala-hca [147.11.189.40])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id p8T9ASL0005218
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 29 Sep 2011 02:10:28 -0700 (PDT)
In-Reply-To: <CAAM7YAmwXyORpFWhthX4iSEkBp7OANnZ8tHruEyN62Z3mnOdLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2011 04:52 PM, Yan, Zheng wrote:
> On Thu, Sep 29, 2011 at 4:25 PM, Rongqing Li<rongqing.li@windriver.com>  wrote:
>> On 09/29/2011 04:16 PM, Yan, Zheng wrote:
>>>
>>> I think the rcu_read_lock protects in6_dev->nd_parms.
>>>
>> It can not protect in6_dev->nd_parms.
>>
>> rcu_read_lock protects the data which is accessed by rcu_XXX,
>>
>
> I'm confused, why does neigh_parms_release() use call_rcu() to release nd_parms.
>

Same as idev, there is a reference on struct neigh_parms
which protects them

-Roy
