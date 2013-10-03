From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 1/2] sit: allow to use rtnl ops on fb tunnel
Date: Thu, 03 Oct 2013 10:06:24 +0200
Message-ID: <524D2580.9040702@6wind.com>
References: <20131001.125923.700243113980583930.davem@davemloft.net>	<524BC816.1000702@6wind.com>	<524BCCE2.8000700@6wind.com> <20131002.170822.1627691739724018976.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	pshelar@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:34894 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637Ab3JCIG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 04:06:28 -0400
Received: by mail-wi0-f176.google.com with SMTP id cb5so8498065wib.3
        for <netdev@vger.kernel.org>; Thu, 03 Oct 2013 01:06:26 -0700 (PDT)
In-Reply-To: <20131002.170822.1627691739724018976.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/10/2013 23:08, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Wed, 02 Oct 2013 09:36:02 +0200
>
>> Le 02/10/2013 09:15, Nicolas Dichtel a =E9crit :
>>> Le 01/10/2013 18:59, David Miller a =E9crit :
>>>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>>> Date: Tue,  1 Oct 2013 18:04:59 +0200
>>>>
>>>>> rtnl ops where introduced by ba3e3f50a0e5 ("sit: advertise tunnel
>>>>> param via
>>>>> rtnl"), but I forget to assign rtnl ops to fb tunnels.
>>>>>
>>>>> Now that it is done, we must remove the explicit call to
>>>>> unregister_netdevice_queue(), because the fallback tunnel is adde=
d to
>>>>> the queue
>>>>> in sit_destroy_tunnels() when checking rtnl_link_ops of all netde=
vices
>>>>> (this
>>>>> is valid since commit 5e6700b3bf98 ("sit: add support of x-netns"=
)).
>>>>>
>>>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>>>
>>>> Applied and queued up for -stable.
>> Another things about ipip: between 0974658da47c ("ipip: advertise
>> tunnel param
>> via rtnl", v3.8) and fd58156e456d ("IPIP: Use ip-tunneling code.",
>> v3.10) the
>> fb device of ipip module has the same problem.
>> Should I send a patch?
>
> Yes please do, thanks for noticing this.
>
In fact, I just notice that 3.9 branch is EoL (bug is only in 3.8 and 3=
=2E9).
Should I still send a patch ? If yes, based on which tree/branch?
