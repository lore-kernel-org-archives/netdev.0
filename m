From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Sat, 14 Nov 2009 10:43:56 +0800
Message-ID: <20091114024356.GA19202@gondor.apana.org.au>
References: <20091110115335.GC6989@redhat.com> <4AF919020200005A000586A9@sinclair.provo.novell.com> <20091110131722.GA19645@redhat.com> <4AF9747E.8020408@novell.com> <20091110143652.GB19645@redhat.com> <4AF98A8C.9040201@novell.com> <20091114011229.GA18580@gondor.apana.org.au> <4AFE08EF.2030308@gmail.com> <20091114022103.GA19020@gondor.apana.org.au> <4AFE15AD.6000208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <ghaskins@novell.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37498 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753856AbZKNCoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 21:44:01 -0500
Content-Disposition: inline
In-Reply-To: <4AFE15AD.6000208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 09:27:57PM -0500, Gregory Haskins wrote:
>
> Clearly there must be _some_ mechanism to synchronize (e.g.
> flush/barrier) though, right?  Otherwise, that interface would seem to
> be quite prone to races and would likely be unusable.   So what does
> said flush use to know when the buffer is free?

It is up to the application to devise its own sync mechanism.
For TCP, you may query the kernel for the last sequence number
acked by the other side.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
