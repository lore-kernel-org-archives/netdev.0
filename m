From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Network performance with small packets - continued
Date: Wed, 09 Mar 2011 18:30:50 -0800
Message-ID: <1299724250.2087.461.camel@tardy>
References: <201103071631.41964.tahm@linux.vnet.ibm.com>
	 <20110309071558.GA25757@redhat.com>
	 <201103091411.09062.tahm@linux.vnet.ibm.com>
	 <20110309215537.GA11516@redhat.com>
	 <1299718745.25664.200.camel@localhost.localdomain>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Tom Lendacky <tahm@linux.vnet.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:29326 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759Ab1CJCaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 21:30:55 -0500
In-Reply-To: <1299718745.25664.200.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-09 at 16:59 -0800, Shirley Ma wrote:
> In theory, for lots of TCP_RR streams, the guest should be able to keep
> sending xmit skbs to send vq, so vhost should be able to disable
> notification most of the time, then number of guest exits should be
> significantly reduced? Why we saw lots of guest exits here still? Is it
> worth to try 256 (send queue size) TCP_RRs?

If these are single-transaction-at-a-time TCP_RRs rather than "burst
mode" then the number may be something other than send queue size to
keep it constantly active given the RTTs.  In the "bare iron" world at
least, that is one of the reasons I added the "burst mode" to the _RR
test - because it could take a Very Large Number of concurrent netperfs
to take a link to saturation, at which point it might have been just as
much a context switching benchmark as anything else :)

happy benchmarking,

rick jones

