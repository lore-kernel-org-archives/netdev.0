From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH] ipv4: Flush per-ns routing cache more sanely.
Date: Fri, 29 Oct 2010 23:41:40 +0200
Message-ID: <4CCB3F94.20709@free.fr>
References: <20101026.103428.179941457.davem@davemloft.net>	 <m1sjzs3hbw.fsf@fess.ebiederm.org>	 <20101026.122022.241452738.davem@davemloft.net> <1288121422.2652.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ebiederm@xmission.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:57204 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755194Ab0J2Vlu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Oct 2010 17:41:50 -0400
In-Reply-To: <1288121422.2652.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2010 09:30 PM, Eric Dumazet wrote:
> Le mardi 26 octobre 2010 =C3=A0 12:20 -0700, David Miller a =C3=A9cri=
t :
>   =20
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Tue, 26 Oct 2010 12:05:39 -0700
>>
>>     =20
>>>> @@ -999,7 +999,7 @@ static int fib_netdev_event(struct notifier_bl=
ock *this, unsigned long event, vo
>>>>   		rt_cache_flush(dev_net(dev), 0);
>>>>   		break;
>>>>   	case NETDEV_UNREGISTER_BATCH:
>>>> -		rt_cache_flush_batch();
>>>> +		rt_cache_flush_batch(dev_net(dev));
>>>>         =20
>>> It still has this incorrect conversion in it.
>>>       =20
>> Sorry I missed that, what's the exact problem with it?
>>     =20
> Because the way _BATCH operation is performed, we call it once...
>
> rollback_registered_many() calls it for the first dev queued in the
> list.
>
> So it should be net independant.
>   =20

Dave,

do you plan to send another version of this patch ? Or can I test it as=
=20
it is ?
Without removing a network device, I can check the routine, no ?

Thanks
   -- Daniel
