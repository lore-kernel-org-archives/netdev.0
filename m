From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pppoe.c: Fix kernel panic caused by __pppoe_xmit
Date: Sat, 11 Dec 2010 21:08:23 +0100
Message-ID: <20101211200823.GA1917@del.dom.local>
References: <20101210091505.GA7868@ff.dom.local>
 <4D023DE4.8000400@ota.si>
 <20101210155510.GA1856@del.dom.local>
 <4D037236.4080903@ota.si>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pstaszewski@artcom.pl,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Gorik Van Steenberge <gvs@zemos.net>,
	Daniel Kenzelmann <kernel.bugzilla@kenzelmann.dyndns.info>,
	Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
To: Andrej Ota <andrej@ota.si>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64126 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587Ab0LKUIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 15:08:30 -0500
Received: by wwa36 with SMTP id 36so4977064wwa.1
        for <netdev@vger.kernel.org>; Sat, 11 Dec 2010 12:08:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4D037236.4080903@ota.si>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 11, 2010 at 01:44:38PM +0100, Andrej Ota wrote:
> __pppoe_xmit function return value was invalid resulting in
> additional call to kfree_skb on already freed skb. This resulted in
> memory corruption and consequent kernel panic after PPPoE peer
> terminated the link.
> 
> This fixes commit 55c95e738da85373965cb03b4f975d0fd559865b.
> 
> Signed-off-by: Jarek Poplawski [jarkao2@gmail.com]
> Signed-off-by: Andrej Ota [andrej@ota.si]
> Reported-by: Pawel Staszewski [pstaszewski@artcom.pl]

Thanks Andrej! I've only updated emails a bit.
Jarek P.

Reported-by: Gorik Van Steenberge <gvs@zemos.net>
Reported-by: Daniel Kenzelmann <kernel.bugzilla@kenzelmann.dyndns.info>
Reported-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Reported-by: Pawel Staszewski <pstaszewski@artcom.pl>
Diagnosed-by: Andrej Ota <andrej@ota.si>
Diagnosed-by: Eric Dumazet <eric.dumazet@gmail.com>
Tested-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Tested-by: Pawel Staszewski <pstaszewski@artcom.pl>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Signed-off-by: Andrej Ota <andrej@ota.si>
