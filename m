From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sit tunnel slow since added GSO/TSO support
Date: Fri, 13 Dec 2013 08:28:44 -0800
Message-ID: <1386952124.19078.148.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52AB322B.7030802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:52844 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872Ab3LMQ2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 11:28:48 -0500
Received: by mail-pb0-f46.google.com with SMTP id md12so2752966pbc.5
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 08:28:48 -0800 (PST)
In-Reply-To: <52AB322B.7030802@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-13 at 17:13 +0100, Michal Schmidt wrote:
> Hello,
> 
> I've been experimenting with IPIP and SIT tunnels. Both of them
> had the support for GSO/TSO added recently, by commits:
>   cb32f511a7 "ipip: add GSO/TSO support"
>   61c1db7fae "ipv6: sit: add GSO/TSO support"
> 
> IPIP works fine for me.
> 
> I am seeing very low TCP performance with SIT if TSO is enabled on the
> SIT interface. It does not matter if the underlying hardware supports
> NETIF_F_GSO_SIT or not (I have tested with bnx2x and tg3).

Strange, my tests were done on bnx2x, and TSO was definitely working ...

I'll take a look, thanks !
