From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 0/8] netfilter: untangle bridge and bridge
 netfilter
Date: Mon, 9 Mar 2015 17:47:23 +0100
Message-ID: <20150309164723.GA3731@salvia>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
 <20150309130253.GA6677@salvia>
 <20150309131356.GB28039@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	azhou@nicira.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150309131356.GB28039@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 09, 2015 at 02:13:56PM +0100, Florian Westphal wrote:
> Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> 
> > I'm preparing a new net-next batch, I can quickly take these three if
> > you agree:
> > 
> > 1/8 bridge: move mac header copying into br_netfilter
> > 2/8 netfilter: bridge: move nf_bridge_update_protocol to where its used
> > 4/8 netfilter: bridge: refactor conditional in br_nf_dev_queue_xmit
> 
> Sure.  I can then submit the entire series (i.e. part1 without these 3
> plus part2).  I have no further br netfilter changes after that.
> 
> > Regarding 3/8, I think we can move that code to br_netfilter.c so we
> > reduce ifdef pollution a bit and keep as much of this monster code
> > fenced under that file. Please, see patch attached.
> 
> Sure.

OK, I'll push these four small changes in the follow nf-next pull
request then, so you and Andry can sort out this. Thanks Florian.
