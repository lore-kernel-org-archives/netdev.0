From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Wed, 28 Jan 2009 11:45:28 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0901281145050.13825@qirst.com>
References: <200901271213.18605.rusty@rustcorp.com.au> <497E705B.5000302@kernel.org> <alpine.DEB.1.10.0901271506580.3114@qirst.com> <20090127.134747.153565246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: tj@kernel.org, rusty@rustcorp.com.au, mingo@elte.hu,
	herbert@gondor.apana.org.au, akpm@linux-foundation.org,
	hpa@zytor.com, brgerst@gmail.com, ebiederm@xmission.com,
	travis@sgi.com, linux-kernel@vger.kernel.org, steiner@sgi.com,
	hugh@veritas.com, netdev@vger.kernel.org,
	mathieu.desnoyers@polymtl.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:37080 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752370AbZA1R5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 12:57:52 -0500
In-Reply-To: <20090127.134747.153565246.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Jan 2009, David Miller wrote:

> > Why wont it scale? this is a separate TLB entry for each processor.
>
> The IA64 per-cpu TLB entry only covers 64k which makes use of it for
> dynamic per-cpu stuff out of the question.  That's why it "doesn't
> scale"

IA64 supports varying page sizes. You can use a 128k TLB entry etc.

