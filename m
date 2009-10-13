From: Massimo Cetra <ctrixk-BBpJ+9iBSNKonA0d6jMUrA@public.gmane.org>
Subject: Re: [Bug #14378] Problems with net/core/skbuff.c
Date: Tue, 13 Oct 2009 12:27:38 +0200
Message-ID: <4AD4561A.5050109@navynet.it>
References: <r-4Wjt4coy.A.CwC.Wal0KB@chimera>	<20091012.034224.64980795.davem@davemloft.net>	<4AD44435.3050703@navynet.it> <20091013.032237.45775304.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ctrixk-BBpJ+9iBSNKonA0d6jMUrA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091013.032237.45775304.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller ha scritto:
> From: Massimo Cetra <ctrixk-BBpJ+9iBSNKonA0d6jMUrA@public.gmane.org>
> Date: Tue, 13 Oct 2009 11:11:17 +0200
>
>   
>> Here, vserver is not involved, and the problem starts at drbd which
>> lives in kernel space (the other oops started at ocfs2).
>>
>> Both ocfs2 and drbd make heavy use of network I/O so i guess the
>> problem is something in the network layer.
>>
>> Anything i can do to help to debugging and solving this issue ?
>>     
>
> Is all of your traffic going over virtio_net?
>   
Yes, indeed.
I'm compiling the patch and i'll let you know.

Thanks,
Max
