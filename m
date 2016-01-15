From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Optimizing instruction-cache, more packets at each stage
Date: Fri, 15 Jan 2016 13:36:04 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCC6613@AcuExch.aculab.com>
References: <20160115142223.1e92be75@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: 'Jesper Dangaard Brouer' <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:60854 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbcAONjQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 08:39:16 -0500
In-Reply-To: <20160115142223.1e92be75@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer
> Sent: 15 January 2016 13:22
...
> I want to do some instruction-cache level optimizations.
> 
> What do I mean by that...
> 
> The kernel network stack code path (a packet travels) is obviously
> larger than the instruction-cache (icache).  Today, every packet
> travel individually through the network stack, experiencing the exact
> same icache misses (as the previous packet).
...

Is that actually true for modern server processors that have large i-cache.
While the total size of the networking code may well be larger, that
part used for transmitting data packets will be much be smaller and
could easily fit in the icache.

	David
