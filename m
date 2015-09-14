From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] atm: deal with setting entry before mkip was called
Date: Mon, 14 Sep 2015 13:08:39 -0400
Message-ID: <55F6FF17.2070404@oracle.com>
References: <1442245730-31575-1-git-send-email-sasha.levin@oracle.com>	 <1442249450.14284.5.camel@edumazet-glaptop2.roam.corp.google.com>	 <55F6FD2A.7080004@oracle.com> <1442250434.14284.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442250434.14284.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/14/2015 01:07 PM, Eric Dumazet wrote:
> On Mon, 2015-09-14 at 13:00 -0400, Sasha Levin wrote:
> 
>> I've tried to be consistent with a similar check within clip_mkip() and
>> clip_setentry():
>>
>>         if (!vcc->push)
>>                 return -EBADFD;
>>
>> So calling clip_setentry() before clip_mkip() would also give you -EBADFD.
>>
> 
> Okay, but -EBADF is not the same than -EBADFD

Doh. Sorry about that.


Thanks,
Sasha
