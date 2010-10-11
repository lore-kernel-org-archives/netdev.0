From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ATM: mpc, fix use after free
Date: Mon, 11 Oct 2010 11:12:47 -0700 (PDT)
Message-ID: <20101011.111247.39182283.davem@davemloft.net>
References: <1286785081.2737.2.camel@edumazet-laptop>
	<1286786794-10410-1-git-send-email-jslaby@suse.cz>
	<1286787580.2737.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jslaby@suse.cz, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47187
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755942Ab0JKSMZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 14:12:25 -0400
In-Reply-To: <1286787580.2737.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Oct 2010 10:59:40 +0200

> Le lundi 11 octobre 2010 =E0 10:46 +0200, Jiri Slaby a =E9crit :
>> Stanse found that mpc_push frees skb and then it dereferences it. It
>> is a typo, new_skb should be dereferenced there.
>>=20
>> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
 ...
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
