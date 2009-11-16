From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Fix the rollback test in dev_change_name()
Date: Mon, 16 Nov 2009 03:31:12 -0800 (PST)
Message-ID: <20091116.033112.150073379.davem@davemloft.net>
References: <20091116093024.GA13115@ff.dom.local>
	<20091116.024936.14048478.davem@davemloft.net>
	<4B0132A6.7090305@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60411
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751645AbZKPLa4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2009 06:30:56 -0500
In-Reply-To: <4B0132A6.7090305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 Nov 2009 12:08:22 +0100

> David Miller a =E9crit :
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Mon, 16 Nov 2009 09:30:24 +0000
>>=20
>>> From: Eric Dumazet <eric.dumazet@gmail.com>
>>>
>>> net: Fix the rollback test in dev_change_name()
>>>
>>> In dev_change_name() an err variable is used for storing the origin=
al
>>> call_netdevice_notifiers() errno (negative) and testing for a rollb=
ack
>>> error later, but the test for non-zero is wrong, because the err mi=
ght
>>> have positive value as well - from dev_alloc_name(). It means the
>>> rollback for a netdevice with a number > 0 will never happen. (The =
err
>>> test is reordered btw. to make it more readable.)
>>>
>>> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
 ...
>> Eric please give your signoff and I'll put this where it needs
>> to go.
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-2.6 and queued for -stable, thanks everyone!
