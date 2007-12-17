From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/3] [UDP6]: Counter increment on BH mode
Date: Mon, 17 Dec 2007 11:42:15 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0712171141530.12871@schroedinger.engr.sgi.com>
References: <474F8255.5060501@cn.fujitsu.com> <20071130111949.GB28277@gerrit.erg.abdn.ac.uk>
 <20071201015438.GC26895@gondor.apana.org.au> <4753AE07.1040906@cn.fujitsu.com>
 <20071203113935.GA25124@gondor.apana.org.au> <20071203114912.GA4425@ms2.inr.ac.ru>
 <20071203115435.GA4202@gondor.apana.org.au> <20071203131723.GA30312@gondor.apana.org.au>
 <20071215135851.GA29063@gondor.apana.org.au> <20071215184327.GA21434@elte.hu>
 <20071216023621.GB959@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Wang Chen <wangchen@cn.fujitsu.com>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>, davem@davemloft.net,
	andi@firstfloor.org, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:56225 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934461AbXLQTmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 14:42:16 -0500
In-Reply-To: <20071216023621.GB959@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Dec 2007, Herbert Xu wrote:

> If we can get the address of the per-cpu counter against
> some sort of a per-cpu base pointer, e.g., %gs on x86, then
> we can do
> 
> 	incq	%gs:(%rax)
> 
> where %rax would be the offset with %gs as the base.  This would
> obviate the need for the CPU ID and therefore avoid disabling
> preemption.
> 
> Hmm, wasn't Christoph working on something like that?

Yes that is what the cpu alloc patchset implements.

