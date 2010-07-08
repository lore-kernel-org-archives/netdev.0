From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] vlan: allow TSO setting on vlan interfaces
Date: Thu, 08 Jul 2010 18:04:39 +0200
Message-ID: <1278605079.2651.37.camel@edumazet-laptop>
References: <1278522874.5906.9.camel@edumazet-laptop>
	 <1278523511.2080.3.camel@achroite.uk.solarflarecom.com>
	 <1278571587.2543.9.camel@edumazet-laptop>
	 <1278581971.2651.10.camel@edumazet-laptop>
	 <1278603804.16013.24.camel@achroite.uk.solarflarecom.com>
	 <1278604198.16013.35.camel@achroite.uk.solarflarecom.com>
	 <4C35F4E4.4070606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33945 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754126Ab0GHQEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 12:04:46 -0400
Received: by wwb24 with SMTP id 24so3984930wwb.1
        for <netdev@vger.kernel.org>; Thu, 08 Jul 2010 09:04:42 -0700 (PDT)
In-Reply-To: <4C35F4E4.4070606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 juillet 2010 =C3=A0 17:55 +0200, Patrick McHardy a =C3=A9cr=
it :

> I agree. The VLAN driver should also propagate feature changes
> upwards itself.

I noticed bonding is also at fault in this area.

bond0.xxx are not noticed of TSO changes on bond0


