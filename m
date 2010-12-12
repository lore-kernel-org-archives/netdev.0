From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: [PATCH] pppoe.c: Fix kernel panic caused by __pppoe_xmit
Date: Sun, 12 Dec 2010 23:02:09 +0200
Message-ID: <201012122302.10330.nuclearcat@nuclearcat.com>
References: <20101210091505.GA7868@ff.dom.local> <4D037236.4080903@ota.si> <20101211200823.GA1917@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrej Ota <andrej@ota.si>,
	=?utf-8?q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pstaszewski@artcom.pl,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Gorik Van Steenberge <gvs@zemos.net>,
	Daniel Kenzelmann <kernel.bugzilla@kenzelmann.dyndns.info>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:41879 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754019Ab0LLVB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Dec 2010 16:01:26 -0500
In-Reply-To: <20101211200823.GA1917@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 11 December 2010 22:08:23 Jarek Poplawski wrote:
> On Sat, Dec 11, 2010 at 01:44:38PM +0100, Andrej Ota wrote:
> > __pppoe_xmit function return value was invalid resulting in
> > additional call to kfree_skb on already freed skb. This resulted in
> > memory corruption and consequent kernel panic after PPPoE peer
> > terminated the link.
> > 
> > This fixes commit 55c95e738da85373965cb03b4f975d0fd559865b.
> > 
> > Signed-off-by: Jarek Poplawski [jarkao2@gmail.com]
> > Signed-off-by: Andrej Ota [andrej@ota.si]
> > Reported-by: Pawel Staszewski [pstaszewski@artcom.pl]
> 
> Thanks Andrej! I've only updated emails a bit.
> Jarek P.
> 
> Reported-by: Gorik Van Steenberge <gvs@zemos.net>
> Reported-by: Daniel Kenzelmann <kernel.bugzilla@kenzelmann.dyndns.info>
> Reported-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
> Reported-by: Pawel Staszewski <pstaszewski@artcom.pl>
> Diagnosed-by: Andrej Ota <andrej@ota.si>
> Diagnosed-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
> Tested-by: Pawel Staszewski <pstaszewski@artcom.pl>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> Signed-off-by: Andrej Ota <andrej@ota.si>
Thanks a lot!
