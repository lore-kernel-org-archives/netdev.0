From: Roland Dreier <roland@topspin.com>
Subject: Re: TCP IP Offloading Interface
Date: 13 Jul 2003 17:20:41 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <52llv2vu06.fsf@topspin.com>
References: <ODEIIOAOPGGCDIKEOPILCEMBCMAA.alan@storlinksemi.com>
	<20030713004818.4f1895be.davem@redhat.com>
	<52u19qwg53.fsf@topspin.com>
	<20030713160200.571716cf.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@storlinksemi.com, linux-kernel@vger.kernel.org,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030713160200.571716cf.davem@redhat.com>
List-Id: netdev.vger.kernel.org

    David> I didn't say I agree with all of Moguls ideas, just his
    David> anti-TOE arguments.  For example, I also think RDMA sucks
    David> too yet he thinks it's a good iea.

Sure, he talks about some weaknesses of TOE, but his conclusion is
that the time has come for OS developers to start working on TCP
offload (for storage).

    David> You obviously don't understand my ideas if you think that
    David> it matters whether there is some relationship between the
    David> MTU and the system page size necessary for the scheme to
    David> work.

I was just quoting part of Mogul's paper that seemed to directly
contradict your original post.  I also said it would be great to see
NIC hardware with support for flow classification.

Look, I pretty much agree with you about TOE hardware.  Every chip
I've seen either requires a bunch of dedicated expensive memory
(including a giant CAM) or is just firmware running on a
low-performance embedded CPU.  But I also think Mogul is right: iSCSI
HBAs are going to force OS designers to deal with TCP offload.

My whole point was just that it doesn't make much sense to dismiss the
whole idea by saying "TOE is evil" and then cite as support a paper
that explains why TOEs now make sense and need to be supported.

 - Roland
