From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] warning in SCTP
Date: Thu, 02 Nov 2006 00:16:43 -0800 (PST)
Message-ID: <20061102.001643.30183952.davem@davemloft.net>
References: <Pine.SOC.4.61.0611020925530.1919@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sri@us.ibm.com,
	lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6873
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750836AbWKBIQo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 03:16:44 -0500
To: mroos@linux.ee
In-Reply-To: <Pine.SOC.4.61.0611020925530.1919@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Meelis Roos <mroos@linux.ee>
Date: Thu, 2 Nov 2006 09:29:16 +0200 (EET)

>    CC [M]  net/sctp/sm_make_chunk.o
> net/sctp/sm_make_chunk.c: In function 'sctp_unpack_cookie':
> net/sctp/sm_make_chunk.c:1358: warning: initialization discards qualifiers from pointer target type
> 
> The reason is that sctp_unpack_cookie() takes a const struct 
> sctp_endpoint and modifies the digest in it (digest being embedded in 
> the struct, not a pointer). So sctp_unpack_cookie really does not use 
> the argument as const, mark it as such.
> 
> Signed-off-by: Meelis Roos <mroos@linux.ee>

Applied, but like your other patch I had to apply it by hand.

Something in your email client adds extra spaces to the patch,
for example:

> diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
> index de313de..ef80489 100644
> --- a/include/net/sctp/sm.h
> +++ b/include/net/sctp/sm.h
> @@ -272,7 +272,7 @@ void sctp_generate_heartbeat_event(unsig
> 
>   void sctp_ootb_pkt_free(struct sctp_packet *);
> 

There should only be one space before the "void" in the patch,
your email client (or something else) put another space there.

Also, your email client likes to turn lines containing only
spaces into empty lines, which also corrupts the patch.
