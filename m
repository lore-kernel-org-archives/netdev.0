From: Tom Herbert <therbert@google.com>
Subject: Re: Generalizing mmap'ed sockets
Date: Fri, 19 Nov 2010 13:55:15 -0800
Message-ID: <AANLkTinCS2LuNv3opCvTcTrxbm5HzFy7JESdu_CzyrFB@mail.gmail.com>
References: <AANLkTi=WF2hAGAufv_Anc=b=Fm2WOpOMOv1UrDRvaTHp@mail.gmail.com>
	<4CE6ED09.70602@hp.com>
	<20101119.135213.15239226.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:55219 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab0KSVzT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 16:55:19 -0500
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id oAJLtHgm001107
	for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 13:55:17 -0800
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by wpaz17.hot.corp.google.com with ESMTP id oAJLtGi8003504
	for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 13:55:16 -0800
Received: by pwi10 with SMTP id 10so1455228pwi.41
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 13:55:16 -0800 (PST)
In-Reply-To: <20101119.135213.15239226.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 19, 2010 at 1:52 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Fri, 19 Nov 2010 13:32:57 -0800
>
>> I suppose then one would be able to track the consumer pointer (on t=
x)
>> to "know" that certain data had been ACKed by the remote? =A0For TCP
>> anyway - and assuming there wouldn't be a case where TCP might copy
>> the data out of the ring and assert "completion."
>
> Yes, that's implicit in his design, the kernel manages the consumer
> pointer in the ring and this is how userspace can see when ring entri=
es
> are reusable.
>

And, for stream sockets the ring would be one big contiguous buffer,
for datagram would be packetized buffer like with packet interface.
