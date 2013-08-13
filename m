From: David Shwatrz <dshwatrz@gmail.com>
Subject: Re: question about netif_rx
Date: Tue, 13 Aug 2013 09:53:50 +0300
Message-ID: <CAJJAcocQ59Kc9a1b=jrNSc1akLLN_74yKANMEmLVmvxoRjX4hw@mail.gmail.com>
References: <alpine.DEB.2.02.1308111151210.2072@localhost6.localdomain6>
	<20130811155640.GA10070@electric-eye.fr.zoreil.com>
	<alpine.DEB.2.02.1308111811440.2072@localhost6.localdomain6>
	<20130813052036.GA11640@electric-eye.fr.zoreil.com>
	<alpine.DEB.2.02.1308130828550.1997@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, grant.likely@linaro.org,
	rob.herring@calxeda.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f51.google.com ([209.85.212.51]:39911 "EHLO
	mail-vb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756720Ab3HMGxw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 02:53:52 -0400
In-Reply-To: <alpine.DEB.2.02.1308130828550.1997@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
Sorry. I still don't understand what checksum has to do with it.
Does GRO depends on Rx/Tx checksum ? I don't think so.

In the napi_gro_receive() we check that the device supports
NETIF_F_GRO, but I don't see that we inspect checksum or that
NETIF_F_GRO is depends on checksum.

Can you please explain how checsum offload is related ?

rgs
David

On Tue, Aug 13, 2013 at 9:29 AM, Julia Lawall <julia.lawall@lip6.fr> wr=
ote:
> On Tue, 13 Aug 2013, Francois Romieu wrote:
>
>> Julia Lawall <julia.lawall@lip6.fr> :
>> > Fran=E7ois Romieu <romieu@fr.zoreil.com> :
>> [...]
>> > > Can you send a netif_receive_skb replacement patch for it ?
>> >
>> > Just to be sure, I just replace netif_rx by netif_receive_skb, not=
hing
>> > else?
>>
>> Yes. It should imho be fine with a comment incluing your analysis an=
d a
>> few words about the current state of checksum offloading support.
>
> I wouldn't know what to say about the checksum part.  It is not suppo=
rted
> so I should use netif_receive_skb?
>
> thanks,
> julia
