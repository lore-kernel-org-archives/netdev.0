From: "La Monte H.P. Yarroll" <piggy@timesys.com>
Subject: Re: [PATCH] Remove prototypes of nonexistent functions from net/sctp
 files
Date: Mon, 19 Jul 2004 10:14:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40FBD734.5040306@timesys.com>
References: <20040718194826.6164.qmail@web53805.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Carl Spalletta <cspalletta@yahoo.com>, lkml <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com,
        ML lksctp <lksctp-developers@lists.sourceforge.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <20040718194826.6164.qmail@web53805.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This function went away in Februrary (change 1.67 on associola.c) due to
changing the assoc id from a kernel address to an abstract address. The
check is now done by looking at a single field in the association struct.

Signed-off-by: La Monte H.P. Yarroll <piggy@baqaqi.chi.il.us>

Carl Spalletta wrote:

>diff -ru linux-2.6.7-orig/net/sctp/socket.c linux-2.6.7-new/net/sctp/socket.c
>--- linux-2.6.7-orig/net/sctp/socket.c  2004-06-15 22:20:26.000000000 -0700
>+++ linux-2.6.7-new/net/sctp/socket.c   2004-07-18 08:54:08.000000000 -0700
>@@ -109,7 +109,6 @@
> static char *sctp_hmac_alg = SCTP_COOKIE_HMAC_ALG;
>
> extern kmem_cache_t *sctp_bucket_cachep;
>-extern int sctp_assoc_valid(struct sock *sk, struct sctp_association *asoc);
>
> /* Look up the association by its id.  If this is not a UDP-style
>  * socket, the ID field is always ignored.
>
>-
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/
>
>  
>

-- 
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell's sig
