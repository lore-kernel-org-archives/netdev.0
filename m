From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave	instead
 of master
Date: Mon, 07 Mar 2011 22:30:57 +0100
Message-ID: <4D754E91.1040208@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-7-git-send-email-jpirko@redhat.com> <4D7249BA.8030401@gmail.com> <20110305144314.GC8573@psychotron.redhat.com> <4D724DB4.9020207@gmail.com> <4D737D00.20406@gmail.com> <20110306133413.GB2795@psychotron.redhat.com> <20110307125059.GA6053@psychotron.brq.redhat.com> <20110307143202.GS11864@gospo.rdu.redhat.com> <4D753C40.2030502@gmail.com> <20110307211957.GB3266@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61775 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853Ab1CGVa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 16:30:59 -0500
Received: by wyg36 with SMTP id 36so4610398wyg.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 13:30:58 -0800 (PST)
In-Reply-To: <20110307211957.GB3266@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/03/2011 22:19, Jiri Pirko a =E9crit :
>>
>> Andy, while you are testing it, can you ensure it also works for the=
 following setup?
>>
>> eth0 ->  bond0 ->  br0 ->  br0.100
>>
>
> I do not think this will work (it never did).

Yes, but it should...

> Bridge reinjects skb, does not do another loop.

Yes, but it should...

> Therefore when skb->dev =3D=3D br0 and vlan_on_bond hook is called, o=
rig_dev =3D=3D br0 as well. + No
> IFF_BONDING is set.

If only bridge returned RX_HANDLER_ANOTHER with skb->dev changed to br0=
=2E.. instead of re-injecting=20
the skb... One more reason to avoid re-injecting.

> I have some kind nice solution in mind and I'm going to submit that a=
s a patch later (too many
> patches are in the wind atm).

Agreed. It's time for others to review, test and ack :-D

	Nicolas.
