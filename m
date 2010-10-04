From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: introduce DST_NOCACHE flag
Date: Mon, 04 Oct 2010 09:19:12 +0200
Message-ID: <1286176752.2712.0.camel@edumazet-laptop>
References: <1285868687.2615.900.camel@edumazet-laptop>
	 <20101003.221846.245388012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42863 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937Ab0JDHTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 03:19:17 -0400
Received: by fxm14 with SMTP id 14so1530315fxm.19
        for <netdev@vger.kernel.org>; Mon, 04 Oct 2010 00:19:16 -0700 (PDT)
In-Reply-To: <20101003.221846.245388012.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 03 octobre 2010 =C3=A0 22:18 -0700, David Miller a =C3=A9cr=
it :

> Cute, and applied, but it shows that we're RCU'd so much of the
> surrounding infrastructure that the neighbour cache is now pretty
> high on the list of things to RCU.

Yes, this is the plan, I began the work friday evening ;)



