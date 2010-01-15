From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Fri, 15 Jan 2010 17:05:35 +0800
Message-ID: <412e6f7f1001150105q2ae70fb2u2e2cfba39a250dc0@mail.gmail.com>
References: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com>
	 <412e6f7f1001141822pffa070ap15c73e2931402294@mail.gmail.com>
	 <20100115.005029.214418777.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:32844 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937Ab0AOJFh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 04:05:37 -0500
In-Reply-To: <20100115.005029.214418777.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 15, 2010 at 4:50 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Fri, 15 Jan 2010 10:22:03 +0800
>
>> For connection based packet processing, such as netfilter,
>> distributing the packets in two directions into one CPU will reduce
>> cache miss, when NAT isn't used. I think the code bellow will help:
>> if (addr1 > addr2)
>> =C2=A0 swap(addr1, addr2);
>
> You can't just do the addresses, the ports will swap too.
>

Yea, and it is just an example.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
