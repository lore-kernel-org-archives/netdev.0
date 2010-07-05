From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] tg3: 64bits stats
Date: Mon, 05 Jul 2010 20:59:46 +0200
Message-ID: <1278356386.2466.3.camel@edumazet-laptop>
References: <1278321242.2877.18.camel@edumazet-laptop>
	 <1278345780.2877.376.camel@edumazet-laptop>
	 <1278351070.2087.70.camel@achroite.uk.solarflarecom.com>
	 <1278353230.2877.601.camel@edumazet-laptop>
	 <1278355263.2087.116.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61106 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009Ab0GES7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 14:59:53 -0400
Received: by wwb24 with SMTP id 24so1966598wwb.1
        for <netdev@vger.kernel.org>; Mon, 05 Jul 2010 11:59:52 -0700 (PDT)
In-Reply-To: <1278355263.2087.116.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 juillet 2010 =C3=A0 19:41 +0100, Ben Hutchings a =C3=A9crit=
 :
> Ugh, I was assuming that callers of dev_get_stats() would hold
> dev_base_lock.  However only netstat_show() seems to do so currently.

Right, but a read_lock() would not be enough, even if all users would
use it.


