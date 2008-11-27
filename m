From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/6] fs: Introduce a per_cpu nr_inodes
Date: Thu, 27 Nov 2008 04:48:49 -0500
Message-ID: <20081127094849.GD13860@infradead.org>
References: <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDC91.3020503@cosmosbay.com> <1227778377.4454.1299.camel@twins> <1227778771.4454.1311.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	kernel-testers@vger.kernel.org, Mike Galbraith <efault@gmx.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>, travis <travis@sgi.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:49580 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbYK0Js4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 04:48:56 -0500
Content-Disposition: inline
In-Reply-To: <1227778771.4454.1311.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 27, 2008 at 10:39:31AM +0100, Peter Zijlstra wrote:
> With it being called from writeback that might not be true for all
> workloads. One thing you can do about it is use the regular per-cpu
> counter stuff, which allows you to do an approximation of the global
> number (it also does all the hotplug stuff for you already).

The way it's used in writeback is utterly stupid and should be fixed :)

But otherwise agreed.

