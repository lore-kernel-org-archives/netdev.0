From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Wed, 28 Jan 2009 12:47:19 -0800 (PST)
Message-ID: <20090128.124719.200850704.davem@davemloft.net>
References: <alpine.DEB.1.10.0901271506580.3114@qirst.com>
	<20090127.134747.153565246.davem@davemloft.net>
	<alpine.DEB.1.10.0901281145050.13825@qirst.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tj@kernel.org, rusty@rustcorp.com.au, mingo@elte.hu,
	herbert@gondor.apana.org.au, akpm@linux-foundation.org,
	hpa@zytor.com, brgerst@gmail.com, ebiederm@xmission.com,
	travis@sgi.com, linux-kernel@vger.kernel.org, steiner@sgi.com,
	hugh@veritas.com, netdev@vger.kernel.org,
	mathieu.desnoyers@polymtl.ca
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56865
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758100AbZA1UrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 15:47:22 -0500
In-Reply-To: <alpine.DEB.1.10.0901281145050.13825@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Wed, 28 Jan 2009 11:45:28 -0500 (EST)

> On Tue, 27 Jan 2009, David Miller wrote:
> 
> > > Why wont it scale? this is a separate TLB entry for each processor.
> >
> > The IA64 per-cpu TLB entry only covers 64k which makes use of it for
> > dynamic per-cpu stuff out of the question.  That's why it "doesn't
> > scale"
> 
> IA64 supports varying page sizes. You can use a 128k TLB entry etc.

Good luck moving to a larger size dynamically at run time.

It really isn't a tenable solution.
