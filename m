From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next] unix: convert printks to pr_<level>
Date: Fri, 6 Dec 2013 17:44:38 +0800
Message-ID: <52A19C86.8030007@huawei.com>
References: <52A16A19.60001@huawei.com> <52A19766.5030308@redhat.com> <52A19992.10803@huawei.com> <52A19B9B.6050000@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <edumazet@google.com>,
	<ebiederm@xmission.com>, <gaofeng@cn.fujitsu.com>,
	<jacob.e.keller@intel.com>, <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:56400 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963Ab3LFJph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 04:45:37 -0500
In-Reply-To: <52A19B9B.6050000@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/6 17:40, Daniel Borkmann wrote:
> On 12/06/2013 10:32 AM, Wang Weidong wrote:
>> On 2013/12/6 17:22, Daniel Borkmann wrote:
>>> On 12/06/2013 07:09 AM, Wang Weidong wrote:
>>>> use pr_<level> instead of printk(LEVEL)
>>>>
>>>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>>>> ---
>>>>    net/unix/af_unix.c |   10 ++++++----
>>>>    1 files changed, 6 insertions(+), 4 deletions(-)
>>>>
>>>> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
>>>> index 4155ed3..ca98e61 100644
>>>> --- a/net/unix/af_unix.c
>>>> +++ b/net/unix/af_unix.c
>>>> @@ -80,6 +80,9 @@
>>>>     *          with BSD names.
>>>>     */
>>>>
>>>> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>>>> +#define DEBUG
>>>> +
>>>
>>> Why do you define DEBUG here ?
>>>
>> I think the pr_debug != printk(KERN_DEBUG), equal when define DEBUG.
> 
> Ok, then please read Documentation/dynamic-debug-howto.txt
> 
> pr_debug() is part of the dynamic debugging framework and
> can be enabled / disabled at runtime when configured. So
> that define does not belong here.
> 
Yes, You are right. I will fix it.

Thanks.

> 
