From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 4/6] fs: Introduce a per_cpu nr_inodes
Date: Thu, 27 Nov 2008 08:46:42 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0811270845410.13647@quilx.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com>  <20081121083044.GL16242@elte.hu>
 <49267694.1030506@cosmosbay.com>  <20081121.010508.40225532.davem@davemloft.net>
  <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com>
 <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com>
 <20081121153453.GA23713@elte.hu>  <492DDC91.3020503@cosmosbay.com>
 <1227778377.4454.1299.camel@twins>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	kernel-testers@vger.kernel.org, Mike Galbraith <efault@gmx.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Hellwig <hch@infradead.org>, travis <travis@sgi.com>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi053.sbcis.sbc.com ([207.115.36.82]:50678 "EHLO
	nlpi053.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbYK0OrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 09:47:22 -0500
In-Reply-To: <1227778377.4454.1299.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Nov 2008, Peter Zijlstra wrote:

> It would be good to get a cpu hotplug handler here and move to
> for_each_online_cpu(). People are wanting distro's to be build with
> NR_CPUS=4096.

NR_CPUS=4096 does not necessarily increase the number of possible cpus.

