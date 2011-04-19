From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Network performance with small packets
Date: Tue, 19 Apr 2011 10:03:43 +0930
Message-ID: <87wrir3wrc.fsf@rustcorp.com.au>
References: <20110127.130240.104065182.davem@davemloft.net> <OF5CFD7B6A.4CBE4E3B-ON6525782B.0014DC5B-6525782B.001979CB@in.ibm.com> <20110202044222.GC3818@redhat.com> <201102091107.20270.rusty@rustcorp.com.au> <1299621444.25664.77.camel@localhost.localdomain> <1299637278.13202.61.camel@localhost.localdomain> <87fwqv4udl.fsf@rustcorp.com.au> <20110412200112.GA19729@redhat.com> <87bp09ax7a.fsf@rustcorp.com.au> <20110414160359.GA11218@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: habanero@linux.vnet.ibm.com, Shirley Ma <mashirle@us.ibm.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com,
	Tom Lendacky <tahm@linux.vnet.ibm.com>, borntraeger@de.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48899 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753602Ab1DSBjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 21:39:07 -0400
In-Reply-To: <20110414160359.GA11218@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Apr 2011 19:03:59 +0300, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> On Thu, Apr 14, 2011 at 08:58:41PM +0930, Rusty Russell wrote:
> > They have to offer the feature, so if the have some way of allocating
> > non-page-aligned amounts of memory, they'll have to add those extra 2
> > bytes.
> > 
> > So I think it's OK...
> > Rusty.
> 
> To clarify, my concern is that we always seem to try to map
> these extra 2 bytes, which thinkably might fail?

No, if you look at the layout it's clear that there's always most of a
page left for this extra room, both in the middle and at the end.

Cheers,
Rusty.
