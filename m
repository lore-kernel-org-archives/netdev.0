From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 7 Oct 2014 22:41:32 +0100
Message-ID: <20141007214132.GA3181@casper.infradead.org>
References: <CAADnVQKKv43aBFCCaEypAosCf+8K64A2oyYEtxw4jQqY0npV5g@mail.gmail.com>
 <20141007.163239.157997964784151921.davem@davemloft.net>
 <CAADnVQJDxPsMeuNmnR5iUwccOKG2A02dZ+3Ae6wGg-RNFPeeeQ@mail.gmail.com>
 <20141007.164802.624713385845633192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, therbert@google.com,
	jesse@nicira.com, gerlitz.or@gmail.com,
	alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	pshelar@nicira.com, azhou@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57583 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754244AbaJGVlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 17:41:36 -0400
Content-Disposition: inline
In-Reply-To: <20141007.164802.624713385845633192.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/14 at 04:48pm, David Miller wrote:
> So we have to write new software in _EVERY_ driver to accomodate this.
> 
> That makes zero sense either, and it is unneeded complexity in the
> hardware.
> 
> COMPLETE works everywhere, on everything, with no driver changes, and
> is so much harder to get wrong.
> 
> Every protocol specific feature has major downsides whether you choose
> to see them or not.

It's probably not overly bold to state that the behaviour behind
CHECKSUM_UNNECESSARY was not created for technical reasons in the
first place.

I enourage NICs to have protocol awareness in the absence of full
programmability but I agree with Dave that there is little to no
reason to expose anything but the full packet checksum to the CPU.
