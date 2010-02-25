From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next PATCH v5 2/3] sysctl: add proc_do_large_bitmap
Date: Thu, 25 Feb 2010 09:17:40 +0800
Message-ID: <4B85CFB4.5030908@redhat.com>
References: <1266752533.3428.28.camel@Nokia-N900-42-11> <201002221829.13987.opurdila@ixiacom.com> <4B84B7F0.7090709@redhat.com> <201002241402.54122.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201002241402.54122.opurdila@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Octavian Purdila wrote:
> On Wednesday 24 February 2010 07:24:00 you wrote:
>> Octavian Purdila wrote:
>>> Here is a new version of this patch which fixes both the comma and
>>> invalid value issues, please give it a try.
>> Sorry, it is even worse. :(
>>
>>> [net-next PATCH v5 2/3] sysctl: add proc_do_large_bitmap
>>>
>>> The new function can be used to read/write large bitmaps via /proc. A
>>> comma separated range format is used for compact output and input
>>> (e.g. 1,3-4,10-10).
>> Writing "50000-50100" gets EINVAL, it should be success.
>> Writing "50000,50100" fails too.
>>
> 
> Hmm, they don't fail for me :-/
> 
>> Please, at least, do some basic testing.
>>
> 
> I do test them, I've attached the current test batch I was using.
> 
> Anyways, today I've noticed that "1,2 3" does not fail and even more 
> importantly the final value is "3". 
> 
> Being that I don't see a way of fixing this without not acknowledging 1,2 even 
> though we will do set these values, I revisited the "1 2 3" issue. And I don't 
> understand why this is actually an issue, we are just being more permissive 
> (i.e. we are allowing as separators both whitespaces and ,).
> 
> 

Oops, after rechecking my test case, it is actually my test case's
fault. Sorry for this. I will fix my test case and run it again.


> 
> I will resend the whole patch series once we get this formatting issue 
> resolved.
> 

Thanks much!
