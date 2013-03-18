From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netfilter: nfnetlink_queue: zero copy support
Date: Mon, 18 Mar 2013 16:36:00 +0100
Message-ID: <20130318153600.GA10854@localhost>
References: <1363576555.29475.122.camel@edumazet-glaptop>
 <20130318092444.GG7938@breakpoint.cc>
 <1363614679.29475.130.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1363614679.29475.130.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 18, 2013 at 06:51:19AM -0700, Eric Dumazet wrote:
> On Mon, 2013-03-18 at 10:24 +0100, Florian Westphal wrote:
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > >
> > > -GRO/GSO packets are segmented in nf_queue()
> > > and checksummed in nfqnl_build_packet_message().
> > > Proper support for GSO/GRO packets (no segmentation,
> > > and no checksumming) needs application cooperation, if we
> > > want no regressions.
> > 
> > Since ipqueue is gone we might be able to push the segmentation
> > down to nfnetlink_queue.  Then new userspace applications
> > could indicate a 'I won't verify checksums and will handle huge
> > packets'.
> > 
> > Are you working on something like this?
> 
> I validated that it was only an API concern, by commenting out the code,
> and got 20Gbps (link speed) using the sample program (using a bigger
> buffer to receive the skbs and removing the printf() for each packet)
> 
> Pablo followed the experiments and I believe he has an idea of the
> needed API.

Will take over this. Florian, ping me if interested in helping.

Thanks a lot for the patch and ideas Eric!
