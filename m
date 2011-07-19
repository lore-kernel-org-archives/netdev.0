From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Tue, 19 Jul 2011 13:17:15 -0700
Message-ID: <1311106635.12882.29.camel@Joe-Laptop>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
	 <1311105738.3113.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4190 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067Ab1GSURQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 16:17:16 -0400
In-Reply-To: <1311105738.3113.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-07-19 at 22:02 +0200, Eric Dumazet wrote:
> Le mardi 19 juillet 2011 =C3=A0 15:52 -0400, Neil Horman a =C3=A9crit=
 :
> > This oops was reported recently when running a pktgen script that c=
alled for a
> > transmitted skb to be cloned and sent 100 times using the clone_skb=
 command to a
> > bridge device with several attached interface:
> BTW you forgot to CC pktgen author, Robert Olsson

Robert, you're not getting cc's on pktgen when
people use get_maintainer.

Are you still interested in getting cc'd on patches
to pktgen?

If so, perhaps you want to add a MAINTAINERS entry
for it.

Maybe something like:

diff --git a/MAINTAINERS b/MAINTAINERS
index 378fccf..5a6c16a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4999,6 +4999,11 @@ S:	Maintained
 F:	drivers/block/pktcdvd.c
 F:	include/linux/pktcdvd.h
=20
+PKTGEN
+M:	Robert Olsson <robert.olsson@its.uu.se>
+S:	Odd Fixes
+F:	net/core/pktgen.c
+
 PKUNITY SOC DRIVERS
 M:	Guan Xuetao <gxt@mprc.pku.edu.cn>
 W:	http://mprc.pku.edu.cn/~guanxuetao/linux


