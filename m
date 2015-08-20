From: tej parkash <parkash.tej@gmail.com>
Subject: Re: netlink_route kernel data dump size increased
Date: Thu, 20 Aug 2015 11:21:01 +0530
Message-ID: <CAM1L+iDUXKSMndnyS+TM3brjxFQU5a0ZRN-SW0JMKLJ+B23OaA@mail.gmail.com>
References: <CAM1L+iBqypLJi2qD3Ncs_L+Lyi=ozRSciZvhBL5OzqjPFGfprg@mail.gmail.com>
 <1440019047.6610.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36764 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544AbbHTFvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 01:51:41 -0400
Received: by pawq9 with SMTP id q9so20089986paw.3
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 22:51:40 -0700 (PDT)
In-Reply-To: <1440019047.6610.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 20, 2015 at 2:47 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-08-19 at 23:41 +0530, tej parkash wrote:
>> All,
>>
>> We are running application on Linux Kernel 3.10 to collect network
>> interface information using  NETLINK_ROUTE protocol. earlier (kernel
>> 2.6.32) we were having 8K buffer allocated to collect all data but
>> with new kernel (3.10) we are seeing read socket error, as buffer size
>> is not sufficient for all network dump data.
>>
>> We want to understand that if the userspace buffer limit increased to
>> 16K or we need some other mechanism to collect the data in 8K chuck.
>> or Is there any other way application can use NETLINK_ROUTE  protocol,
>> so that it will not break the application if data size gets increased
>> in future.
>>
>> I did some some browsing and found some link but they were not very conclusive.
>> http://www.spinics.net/lists/netdev/msg162185.html
>>
>> Appreciate for any kind of help or pointers here
>>
>
> This sounds like a bug that might have been fixed later.

Ok, let me see if I could find related fix in later kernels.  If you
have any other pointers here please let me know.

>
> User space is not required to switch to 16KB, although it is recommended
> to reduce number of syscalls.


Are you saying that we should bring back the fix to 3.10 kernel rather
increasing user space buffer size to 16KB. I assume that would be
right way to handle it. But do we have any issue if we just increase
the buffer size to 16KB (e.g without fix, 16KB may also not be
sufficient sometime, etc)


>
>
