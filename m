From: Bernard Metzler <BMT@zurich.ibm.com>
Subject: Re: software iwarp stack update
Date: Thu, 23 Sep 2010 17:25:07 +0200
Message-ID: <OF2701BEF6.34F9E96B-ONC12577A7.00547489-C12577A7.0054B2EC@ch.ibm.com>
References: <4C9A6A2A.2020509@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, linux-rdma@vger.kernel.org,
	linux-rdma-owner@vger.kernel.org, Matthew Wilcox <matthew@wil.cx>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	netdev@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:35585 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998Ab0IWPZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 11:25:21 -0400
In-Reply-To: <4C9A6A2A.2020509@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



linux-rdma-owner@vger.kernel.org wrote on 09/22/2010 10:42:18 PM:

> On 09/22/2010 03:35 PM, Nicholas A. Bellinger wrote:
> > On Wed, 2010-09-22 at 10:19 +0200, Bernard Metzler wrote:
> >
> >> Earlier this year, we announced the availability of an open source,
> >> full software implementation of the iWARP RDMA protocol stack - see
> >> my email "software iwarp stack" from March 14th at the linux-rdma list
> >> (http://www.mail-archive.com/linux-rdma@vger.kernel.org/msg02940.html)
> >> While since then working on performance and stability, we provided
> >> some source code updates. Current user and kernel code is available at
> >> gitorious.org/softiwarp. Please see the CHANGES file in the
> >> kernel/ directory for a summary of the most recent changes.
> >>
> >> For more convenient testing, the latest update now allows for a
> >> stand-alone build of the kernel module without full kernel source
> >> code access. We tested the code with kernel version 2.6.34. If
> >> you are interested in a full software RDMA stack on Ethernet,
> >> please try it out.
> >>
> >> In the hope of providing useful information, I put
> >> netdev@vger.kernel.org on copy. Subscribers of this list,
> >> please put me on private cc in case you reply or comment, since
> >> I am not subscribed to the list.
> >> We would be more than happy if you netdev folks would consider
> >> a hardware independent RDMA kernel service as something useful and
> >> potentially to be integrated into the mainline network stack.
> >>
> >> Why might it be useful?
> >> A software RDMA stack makes the semantic advantages of
> >> asynchronous and one-sided communication available while obsoleting
> >> the need to deploy dedicated RDMA hardware or any protocol offloading
> >> (while not matching the lowest delay numbers of real RDMA hardware).
> >> Implementing the IETF's iWARP protocol stack on top of TCP kernel
> >> sockets, softiwarp integrates with the open fabrics environment
> >> and thus exports the RDMA kernel and user verbs interface.
> >>
> >> The efficiency of the Linux TCP/IP network stack together with
intrinsic
> >> advantages of the RDMA communication model (async. posting of work
> >> and reaping of work completions, transfer of send buffer ownership
> >> to the kernel which enables zero copy transmit, peer data placement
> >> without application scheduling, one-sided remote read operations etc.)
> >> can result in improved application-to-application performance and
> >> less CPU load, while using the unchanged kernel TCP stack.
> >>
> >> A software RDMA stack might promote wider RDMA deployment,
> >> since when using the host TCP stack, it enables RDMA semantic
> >> independent of dedicated hardware. softiwarp peers with real
> >> RNICs (tested with Chelsio's T3 adapter).
> >>
> >> softiwarp is still work in progress and we are very thankful for any
> >> suggestions/comments/bug reports. Please advise how we should proceed
> >> to bring the stack further to your attention. Would it be useful to
> >> provide patches against the current stable kernel version or the next
> >> release candidate?
> >>
> >>
> > Hi Bernard,
> >
> > So what I would recommend doing here to make things more appealing to
> > DaveM and other interested NetDev folks would be to clone a seperate
> > tree from the net-2.6.git or net-next-2.6.git repositories and include
> > the softiwarp/kernel.git code into a fresh 'in-kernel' clone tracking
> > the latest netdev code, and then keep git rebase'ing against DaveM's
> > last changes and update your local tree to the lastest netdev code.
> >
> > Of course you will want to remove all of the 'out of tree'
LINUX_VERSION
> > build macros and any other legacy bits to follow mainline kernel
> > convention for your 'in-kernel' softiwarp tree.
> >
> >
>
> And then post a patch series for review.
>

All,

Yes, ok, thats what I will do now.
Many thanks for the helpful and encouraging replies.

Bernard.

