From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/6] net: pack skb_shared_info more efficiently
Date: Thu, 05 Jan 2012 19:30:58 +0100
Message-ID: <1325788258.4759.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	 <1325783624-14601-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:46484 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753099Ab2AESbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:31:02 -0500
Received: by wibhm6 with SMTP id hm6so557406wib.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 10:31:01 -0800 (PST)
In-Reply-To: <1325783624-14601-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 janvier 2012 =C3=A0 17:13 +0000, Ian Campbell a =C3=A9crit =
:
> nr_frags can be 8 bits since 256 is plenty of fragments. This allows =
it to be
> packed with tx_flags.
>=20
> Also by moving ip6_frag_id and dataref (both 4 bytes) next to each ot=
her we can
> avoid a hole between ip6_frag_id and frag_list on 64 bit systems.
>=20
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> ---


Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
