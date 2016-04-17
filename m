From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [Odd commit author id merge via netdev]
Date: Sat, 16 Apr 2016 17:13:44 -0700
Message-ID: <5712D538.10305@oracle.com>
References: <56FEB50E.4060004@oracle.com>
 <1459540904.3342.2.camel@sipsolutions.net> <56FEF2F6.4090302@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39250 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335AbcDQANw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 20:13:52 -0400
In-Reply-To: <56FEF2F6.4090302@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/1/2016 3:15 PM, santosh shilimkar wrote:
> On 4/1/2016 1:01 PM, Johannes Berg wrote:
>> On Fri, 2016-04-01 at 10:51 -0700, santosh shilimkar wrote:
>>> Hi Dave,
>>>
>>> I noticed something odd while checking the recent
>>> commits of mine in kernel.org tree made it via netdev.
>>>
>>> Don't know if its patchwork tool doing this.
>>> Usual author line in my git objects    :
>>>     Author: Santosh Shilimkar <emaid-id>
>>>
>>> But the commits going via your tree seems to be like below..
>>>     Author: email-id <email-id>
>>>
>>> Few more examples of the commits end of the email. Can this
>>> be fixed for future commits ? The git objects you pulled from
>>> my tree directly have right author format where as ones which
>>> are picked from patchworks seems to be odd.
>>>
>>
>> Patchwork does store this info somehow and re-use it, quite possibly
>> from the very first patch you ever sent. I think this bug was *just*
>> fixed in patchwork, but it'll probably be a while until that fix lands.
>>
>> However, you can go and create a patchwork account with the real name,
>> associate it with all the email addresses you use and then I think
>> it'll pick it up. Not entirely sure though, you'll have to test it.
>>
Thought of letting you know that creating username didn't
seems to help. I did create a patchwork account and associated
the email ids I use for commits after last email exchange.

Now it got tested with Dave's 'net' tree commits indirectly.
The patchwork commit format still seems to be
"Author: email-id <email-id>" irrespective of patchwork user
name for me.

Regards,
Santosh
