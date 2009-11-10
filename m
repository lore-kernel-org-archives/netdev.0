From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Tue, 10 Nov 2009 18:48:15 +0800
Message-ID: <412e6f7f0911100248mbc14287p26c43141d6ab202c@mail.gmail.com>
References: <4AF924A5.1050303@gmail.com> <4AF9406C.8010603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:49834 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbZKJKsK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 05:48:10 -0500
Received: by pwi3 with SMTP id 3so1218857pwi.21
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 02:48:15 -0800 (PST)
In-Reply-To: <4AF9406C.8010603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2009 at 6:29 PM, Patrick McHardy <kaber@trash.net> wrot=
e:
>
> I'm not sure how this will help, ifb device transmission is
> still serialized by the ingress queue lock and the mirred lock.
>

But not in ifb_thread. For firewall the main routine is after
netif_rx_ni(). For server applications, the packets belong to the same
flow are always routed to the same CPU, and the applications can
benefit with better localization.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
