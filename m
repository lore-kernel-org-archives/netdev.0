From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Bug 6936] BUG: warning at
 net/core/dev.c:1171/skb_checksum_help()
Date: Wed, 16 Aug 2006 11:06:31 -0700
Message-ID: <20060816110631.42b20c77@localhost.localdomain>
References: <200608151829.k7FITxKM006438@fire-2.osdl.org>
	<20060816012900.GA23430@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:45986 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932173AbWHPSNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 14:13:01 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060816012900.GA23430@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 16 Aug 2006 11:29:00 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, Aug 15, 2006 at 11:29:59AM -0700, bugme-daemon@bugzilla.kernel.org wrote:
> > http://bugzilla.kernel.org/show_bug.cgi?id=6936
> 
> It's actually a bug in the bridging code :)
> 
> [BRIDGE]: Disable SG/GSO if TX checksum is off
> 
> When the bridge recomputes features, it does not maintain the
> constraint that SG/GSO must be off if TX checksum is off.
> This patch adds that constraint.
> 
> On a completely unrelated note, I've also added TSO6 and TSO_ECN
> feature bits if GSO is enabled on the underlying device through
> the new NETIF_F_GSO_SOFTWARE macro.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Cheers,

agree. I assume this came in with the new GSO for 2.6.18 or do we need
to fix 2.6.17 as well.
