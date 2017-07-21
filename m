From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/2] net-next: add a dma_desc element to struct
 skb_shared_info
Date: Fri, 21 Jul 2017 20:21:13 +0100 (WEST)
Message-ID: <20170721.202113.583238690576835181.davem@davemloft.net>
References: <20170721152035.6645-2-john@phrozen.org>
        <1500652599.3924.10.camel@redhat.com>
        <6bcc6463-c2e7-5f56-22b0-f49bb369ce1c@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, edumazet@google.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: john@phrozen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6bcc6463-c2e7-5f56-22b0-f49bb369ce1c@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Crispin <john@phrozen.org>
Date: Fri, 21 Jul 2017 19:01:57 +0200

> When the flow offloading engine forwards a packet to the DMA it will
> send additional info to the sw path. this includes
> * physical switch port
> * internal flow hash - this is required to populate the correct flow
> * table entry
> * ppe state - this indicates what state the PPEs internal table is in
> * for the flow
> * the reason why the packet was forwarde - these are things like bind,
> * unbind, timed out, ...
> 
> once the flow table offloading patches are ready and upstream, the
> netfilter layer will see the SKB and pass it o to the flow table
> offloading code, at which point it will finally end up inside the
> offloading driver. this will need to have access to this info sent to
> the sw path inside the rx descriptor to properly work out what state
> the flow is in and which table entry to populate in the HW table for
> offloading to work.

You absolutely must justify any change to a core data structure
alongside the complete and full set of patches that actually make use
of that data structure change.

You can't just say "here is the data structure change and BTW what
actually uses this is somewhere else, and not here on the list yet."

That makes it impossible to 1) evaluate the correctness of your change
and 2) validate the actual use so we can suggest alternative schemes
and/or approaches.

So please don't suggest changes this way.

Thanks.
