From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Sat, 14 Nov 2009 10:21:03 +0800
Message-ID: <20091114022103.GA19020@gondor.apana.org.au>
References: <20091002141407.30224.54207.stgit@dev.haskins.net> <20091110115335.GC6989@redhat.com> <4AF919020200005A000586A9@sinclair.provo.novell.com> <20091110131722.GA19645@redhat.com> <4AF9747E.8020408@novell.com> <20091110143652.GB19645@redhat.com> <4AF98A8C.9040201@novell.com> <20091114011229.GA18580@gondor.apana.org.au> <4AFE08EF.2030308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <ghaskins@novell.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32785 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753400AbZKNCVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 21:21:06 -0500
Content-Disposition: inline
In-Reply-To: <4AFE08EF.2030308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 08:33:35PM -0500, Gregory Haskins wrote:
>
> Well, not with respect to the overall protocol, of course not.  But with
> respect to the buffer in question, it _has_ to be.  Or am I missing
> something?

sendfile() has never guaranteed that the kernel is finished with
the underlying pages when it returns.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
