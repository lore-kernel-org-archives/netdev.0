From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 8151] New: Established connections not displayed in /proc/tcp/netstat
Date: Fri, 09 Mar 2007 18:13:17 +1100
Message-ID: <E1HPZHx-00083P-00@gondolin.me.apana.org.au>
References: <20070308101947.f77ab27f.akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	getitupsidelines@yahoo.com
To: akpm@linux-foundation.org (Andrew Morton)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3139 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S2993027AbXCIHNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 02:13:21 -0500
In-Reply-To: <20070308101947.f77ab27f.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> Date: Thu, 8 Mar 2007 07:53:57 -0800
> From: bugme-daemon@bugzilla.kernel.org
> To: bugme-new@lists.osdl.org
> Subject: [Bugme-new] [Bug 8151] New: Established connections not displayed in /proc/tcp/netstat

Please try running 'ss -nt' to see if it displays the missing
connections.  If it does then we can confirm a problem with
/proc, otherwise the you might have a TCP problem instead.

Note that with a recent kernel you may have to build/load the
tcp_diag module before 'ss -nt' will work.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
