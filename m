From: David Miller <davem@davemloft.net>
Subject: Re: TCP packet size and delivery packet decisions
Date: Mon, 06 Sep 2010 22:30:10 -0700 (PDT)
Message-ID: <20100906.223010.173858342.davem@davemloft.net>
References: <AANLkTikMPENe011GxK15TNTXwdckZSSYfb=3pdDwfUeG@mail.gmail.com>
	<20100906.221644.123986391.davem@davemloft.net>
	<AANLkTik75BGz=csDKVRk+Ni9__MqXMpHeqi_sHniu09A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: leandroal@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50927
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751083Ab0IGF3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 01:29:52 -0400
In-Reply-To: <AANLkTik75BGz=csDKVRk+Ni9__MqXMpHeqi_sHniu09A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ツ Leandro Melo de Sales <leandroal@gmail.com>
Date: Tue, 7 Sep 2010 02:21:42 -0300

> This is a embedded system implemented in a proprietary hardware that I
> can send TCP commands to turn on/off relays. It will be very difficult
> to find the reason for this behaviour. Since it needs to receive very
> small data, probably it is not necessary to scaling window.

The small 78 byte window is why the sending system is splitting up the
writes into smaller pieces.

I presume that the system advertises exactly a 78 byte window because
this is how large the commands are.  But this is an extremely foolish
and baroque thing to do, and it's why you are having problems.
