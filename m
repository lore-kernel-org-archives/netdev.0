From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 21 Apr 2017 12:11:01 -0400 (EDT)
Message-ID: <20170421.121101.2089838344873192132.davem@davemloft.net>
References: <82a6c32b-d58e-aeed-bfb5-546f328eaf35@mojatatu.com>
        <20170421.113800.1367091481085913667.davem@davemloft.net>
        <c2d61246-b92d-efef-cd07-005f8a8dacc0@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36604 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1039979AbdDUShg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:37:36 -0400
In-Reply-To: <c2d61246-b92d-efef-cd07-005f8a8dacc0@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Fri, 21 Apr 2017 11:55:40 -0400

> On 17-04-21 11:38 AM, David Miller wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>> Date: Fri, 21 Apr 2017 11:29:19 -0400
>>
>> Even something as benign as "give melarger action dumps" _must_ still
>> have the same behavior because the user has no alternative action plan
>> possible if it cannot tell if the kernel supports the facility or not.
>>

   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

I am pretty sure I was clear in my position above.  And then you say:

> But i think there are other cases like "please give me a large
> dump" which require less harsh reaction in particular because
> I have alternative means in the kernel to achieve the dump.
> Would logging or no reaction be fine then?

I clearly said that the large dump should be handled the exactly the
same way as other kinds of attributes and requests.  And I told you
why, and it's because the user cannot act upon the situation if it
wants to.

You give the user no way to perform alternative actions.

Any feature whatsoever, even "give me large dumps" may require the
user to take alternative actions.  You give the user no option
whatsoever by silently ignoring stuff, and that is simply
unacceptable.

Please get out of the mindset of "oh, ignoring this and silently
proceeding in situation X is OK".

Thanks.
