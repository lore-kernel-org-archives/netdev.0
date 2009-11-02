From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] veth: Fix unregister_netdevice_queue for
 veth
Date: Sun, 01 Nov 2009 23:56:31 -0800 (PST)
Message-ID: <20091101.235631.218735260.davem@davemloft.net>
References: <m1hbtgmqew.fsf@fess.ebiederm.org>
	<m1639wjshq.fsf_-_@fess.ebiederm.org>
	<4AEC0653.8050109@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, xemul@openvz.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40874
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754124AbZKBH4H convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 02:56:07 -0500
In-Reply-To: <4AEC0653.8050109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 31 Oct 2009 10:41:39 +0100

> Eric W. Biederman a =E9crit :
>> I tested the recent unregister many changes and got a weird,
>> nasty and seemingly unrelasted kernel oops. Changing
>> unregister_netdevice_queue to use list_move_tail fixes
>> the problem for me.
>>=20
>> ip link add type veth
>> rmmod veth
>>=20
>> ls /sys/class/net/
>> showed one of the veth devices still present.
>>=20
>> A subsequent ip link oopsed the box.
>>=20
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
 ...
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
