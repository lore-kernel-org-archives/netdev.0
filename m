From: Ming Zhang <mingz@ele.uri.edu>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
	Topics
Date: Sat, 02 Apr 2005 14:13:21 -0500
Message-ID: <1112469200.4599.4.camel@localhost.localdomain>
References: <20050324215922.GT14202@opteron.random>
	 <424346FE.20704@cs.wisc.edu> <20050324233921.GZ14202@opteron.random>
	 <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random>
	 <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop>
	 <20050326224621.61f6d917.davem@davemloft.net> <52vf7bwo4w.fsf@topspin.com>
	 <1112042936.5088.22.camel@beastie>  <20050328223203.GC28983@kvack.org>
	 <1112465317.24936.10.camel@mylaptop>
Reply-To: mingz@ele.uri.edu
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, mpm@selenic.com, andrea@suse.de,
        michaelc@cs.wisc.edu, James.Bottomley@HansenPartnership.com,
        ksummit-2005-discuss@thunk.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: open-iscsi <open-iscsi@googlegroups.com>
In-Reply-To: <1112465317.24936.10.camel@mylaptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-04-02 at 13:08, Dmitry Yusupov wrote:
> On Mon, 2005-03-28 at 17:32 -0500, Benjamin LaHaise wrote:
> > On Mon, Mar 28, 2005 at 12:48:56PM -0800, Dmitry Yusupov wrote:
> > > If you have plans to start new project such as SoftRDMA than yes. lets
> > > discuss it since set of problems will be similar to what we've got with
> > > software iSCSI Initiators.
> > 
> > I'm somewhat interested in seeing a SoftRDMA project get off the ground.  
> > At least the NatSemi 83820 gige MAC is able to provide early-rx interrupts 
> > that allow one to get an rx interrupt before the full payload has arrived 
> > making it possible to write out a new rx descriptor to place the payload 
> > wherever it is ultimately desired.  It would be fun to work on if not the 
> > most performant RDMA implementation.
> 
> I see a lot of skepticism around early-rx interrupt schema. It might
> work for gige, but i'm not sure if it will fit into 10g.
> 
> What RDMA gives us is zero-copy on receive and new networking api which
> has a potential to be HW accelerated. SoftRDMA will never avoid copying
> on receive. But benefit for SoftRDMA would be its availability on client
> sides. It is free and it could be easily deployed. Soon Intel & Co will
> give us 2,4,8... multi-core CPUs for around 200$ :), So, who cares if
> one of those cores will do receive side copying?
> 
dedicated core to dealing with interrupt is fine. but the memory
bandwidth is still over-used right?

ming
