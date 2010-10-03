From: Robin Holt <holt@sgi.com>
Subject: Re: [Patch] Limit sysctl_tcp_mem and sysctl_udp_mem initializers
 to prevent integer overflows.
Date: Sun, 3 Oct 2010 06:16:16 -0500
Message-ID: <20101003111616.GS14064@sgi.com>
References: <20101002112405.951704198@gulag1.americas.sgi.com>
 <20101002112419.248437367@gulag1.americas.sgi.com>
 <1286025736.2582.1827.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Robin Holt <holt@sgi.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Willy Tarreau <w@1wt.eu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:56034 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753056Ab0JCLQT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Oct 2010 07:16:19 -0400
Content-Disposition: inline
In-Reply-To: <1286025736.2582.1827.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 02, 2010 at 03:22:16PM +0200, Eric Dumazet wrote:
> Le samedi 02 octobre 2010 =E0 06:24 -0500, Robin Holt a =E9crit :
=2E..
> Strange, you mention sctp in changelog but I cant see the patch.

After looking at the patch, I realized it really belonged in a separate
change and sent that to the sctp mailing list without noticing I forgot
to Cc: lkml.

> We can switch infrastructure to use long "instead" of "int", now
> atomic_long_t primitives are available for free.
>=20
> Reported-by: Robin Holt <holt@sgi.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Reviewed-by: Robin Holt <holt@sgi.com>
