From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Mon, 28 Mar 2005 17:32:03 -0500
Message-ID: <20050328223203.GC28983@kvack.org>
References: <20050324215922.GT14202@opteron.random> <424346FE.20704@cs.wisc.edu> <20050324233921.GZ14202@opteron.random> <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop> <20050326224621.61f6d917.davem@davemloft.net> <52vf7bwo4w.fsf@topspin.com> <1112042936.5088.22.camel@beastie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: open-iscsi@googlegroups.com, "David S. Miller" <davem@davemloft.net>,
        mpm@selenic.com, andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Yusupov <dmitry_yus@yahoo.com>
Content-Disposition: inline
In-Reply-To: <1112042936.5088.22.camel@beastie>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 28, 2005 at 12:48:56PM -0800, Dmitry Yusupov wrote:
> If you have plans to start new project such as SoftRDMA than yes. lets
> discuss it since set of problems will be similar to what we've got with
> software iSCSI Initiators.

I'm somewhat interested in seeing a SoftRDMA project get off the ground.  
At least the NatSemi 83820 gige MAC is able to provide early-rx interrupts 
that allow one to get an rx interrupt before the full payload has arrived 
making it possible to write out a new rx descriptor to place the payload 
wherever it is ultimately desired.  It would be fun to work on if not the 
most performant RDMA implementation.

> I'm not a believer in any HW state-full protocol offloading technologies
> and that was one of my motivations to initiate Open-iSCSI project to
> prove that performance is not an issue anymore. And we succeeded, by
> showing comparable to iSCSI HW Initiator's numbers.

Agreed.  After working on a full TOE implementation, I think that the 
niche market most TOE vendors are pursuing is not one that the Linux 
community will ever develop for.  Hardware vendors that gradually add 
offloading features from the NIC realm to speed up the existing network 
stack are a much better fit with Linux.

> Though, for me, RDMA over TCP is an interesting topic from software
> implementation point of view. I was thinking about organizing new
> project. If someone knows that related work is already started - let me
> know since I might be interested to help.

Shall we create a new mailing list?  I guess it's time to update 
majordomo... =)

		-ben
