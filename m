From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH] net: Fix ifdef typo in net_device definition
Date: Mon, 11 May 2015 12:52:43 -0700
Message-ID: <5551088B.3000700@gmail.com>
References: <20150511183152.13432.73713.stgit@ahduyck-vm-fedora22> <5550F74B.6030301@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Daniel Borkmann <daniel@iogearbox.net>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36366 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041AbbEKTwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 15:52:45 -0400
Received: by pabsx10 with SMTP id sx10so117753977pab.3
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 12:52:44 -0700 (PDT)
In-Reply-To: <5550F74B.6030301@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/11/2015 11:39 AM, Daniel Borkmann wrote:
> On 05/11/2015 08:31 PM, Alexander Duyck wrote:
>> While trying to build for some performance testing I received the error
>> message below multiple times:
>>
>> include/linux/netdevice.h:1658:5: warning: "CONFIG_NET_CLS_ACT" is 
>> not defined [-Wundef]
>>   #if CONFIG_NET_CLS_ACT
>>
>> It looks like this was just a typo and should have been "#ifdef" 
>> instead of
>> "#if".
>>
>> Fixes: d2788d34885d4 ("net: sched: further simplify handle_ing")
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>
> It's already here, sorry for that:
>
> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=4cda01e86f68dacc758b2daf6e8809f2ce915b85
>
> Best,
> Daniel

No problem.  Just as long as it is fixed I am happy since it is one less 
patch to carry in my tree.

- Alex
