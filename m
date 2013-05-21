From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] sock_diag: notify packet socket
 creation/deletion
Date: Tue, 21 May 2013 11:43:56 -0700 (PDT)
Message-ID: <20130521.114356.1770768038835716108.davem@davemloft.net>
References: <1368800738-4364-1-git-send-email-nicolas.dichtel@6wind.com>
	<20130519.232925.1972249319855411715.davem@davemloft.net>
	<519B8F6A.7010406@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53436 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488Ab3EUSn5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 14:43:57 -0400
In-Reply-To: <519B8F6A.7010406@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 21 May 2013 17:14:50 +0200

> Le 20/05/2013 08:29, David Miller a =E9crit :
>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Date: Fri, 17 May 2013 16:25:38 +0200
>>
>>> With this patch, a netlink message is sent each time a packet socke=
t
>>> is created or deleted.  The framework is generic, so it's easy to
>>> add the notification for other kind of sockets.
>>>
>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>
>> Just curious what you want to use this for.
> Some HW (custom FPGA, ASICs, NPUs) are able to offload packet
> captures, so it is required to notify them.

I don't even want to hear about this until you have patches ready
to submit to fully support such a facility.

I'm not applying this patch, sorry.
