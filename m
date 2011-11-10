From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: dst->obsolete has become pointless
Date: Thu, 10 Nov 2011 01:33:43 +0100
Message-ID: <1320885223.5825.37.camel@edumazet-laptop>
References: <1320842948.6923.3.camel@Joe-Laptop>
	 <20111109.142044.1307358041881082836.davem@davemloft.net>
	 <1320882969.6923.29.camel@Joe-Laptop>
	 <20111109.192427.661860445333469011.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joe@perches.com, steffen.klassert@secunet.com,
	netdev@vger.kernel.org, timo.teras@iki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62636 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932214Ab1KJAds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 19:33:48 -0500
Received: by wwh12 with SMTP id 12so1515016wwh.1
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 16:33:47 -0800 (PST)
In-Reply-To: <20111109.192427.661860445333469011.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 09 novembre 2011 =C3=A0 19:24 -0500, David Miller a =C3=A9c=
rit :

> We can only use it in this scenerio if it universally
> uses the same type.  This is due to the by-hand layout
> of the rest of the structure such that __refcnt ends
> up on a different cache line.
> --

tbench (or any tcp on loopback workload) is currently hitting a single
dst refcnt because a single dst is shared by all sockets...

Now some information was migrated to inetpeer, I wonder if we could not
allocate a private dst for a socket ?

Just an idea before the night...
