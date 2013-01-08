From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net: introduce skb_transport_header_was_set()
Date: Tue, 08 Jan 2013 09:05:13 -0500
Message-ID: <50EC2799.4070103@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50CCE961.5050204@mojatatu.com>  <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr>  <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com>  <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com>  <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr>  <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com>  <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com>  <50D06177.2090905@mojatatu.com>  <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com>  <50D1A8A7.1090002@mojatatu.com> <50D1AB7E.5060000@mojatatu.com>  <50D2D229.6040802@gmail.com> <50D305FD.7000901@mojatatu.com>  <50D327CD.3050904@gmail.com> <50D45E25.7050703@mojatatu.com>  <50D46060.2070308@gmail.com> <50D46928.9070809@mojatatu.c
 om>  <alpine.LNX.2.01.1212211533360.957@nerf07.vanv.qr>  <1356104720.21834.7497.camel@edumazet-glaptop>  <50D5B8BA.9010808@mojatatu.com> <1357586901.6919.3551.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:40873 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756190Ab3AHOFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 09:05:22 -0500
Received: by mail-ie0-f181.google.com with SMTP id 16so488561iea.40
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 06:05:22 -0800 (PST)
In-Reply-To: <1357586901.6919.3551.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-01-07 02:28 PM, Eric Dumazet wrote:

> Note that network stacks usually reset the transport header anyway,
> after pulling the network header, so this change only allows
> a followup patch to have more precise qdisc pkt_len computation
> for GSO packets at ingress side.
>

Looks good to me.

cheers,
jamal
