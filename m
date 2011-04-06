From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 32772] New: PROBLEM: kernel BUG at net/ipv4/inetpeer.c:386
Date: Wed, 06 Apr 2011 11:16:49 -0700 (PDT)
Message-ID: <20110406.111649.193697123.davem@davemloft.net>
References: <1302105923.3209.103.camel@edumazet-laptop>
	<1302107123.3209.113.camel@edumazet-laptop>
	<BANLkTinhnPR6fHRQD-vvbxX1n+Zxr=HTZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: dimetrios@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36594
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754476Ab1DFSRZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 14:17:25 -0400
In-Reply-To: <BANLkTinhnPR6fHRQD-vvbxX1n+Zxr=HTZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Dmitry Novikov <dimetrios@gmail.com>
Date: Wed, 6 Apr 2011 21:15:17 +0300

> 2011/4/6 Eric Dumazet <eric.dumazet@gmail.com>
>>
>> Le mercredi 06 avril 2011 =E0 18:05 +0200, Eric Dumazet a =E9crit :
>>
>> >
>> > This reminds me a possible memory corruption (from another layer)
>> >
>>
>> I found the reference of a past bug report, where slub_nomerge was u=
sed
>> too.
>>
>> =A0http://www.spinics.net/lists/netdev/msg154206.html
>>
>>
>>
> I will schedule reboot in 6 hours so that slub_nomerge parmeter been =
applied

Thanks for helping us track this down.
