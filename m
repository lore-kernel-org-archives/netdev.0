From: Rik van Riel <riel@redhat.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
 Topics
Date: Wed, 30 Mar 2005 10:38:34 -0500 (EST)
Message-ID: <Pine.LNX.4.61.0503301037290.27330@chimarrao.boston.redhat.com>
References: <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop>
 <20050326224621.61f6d917.davem@davemloft.net>
 <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
 <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave>
 <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie>
 <1112130512.1077.107.camel@jzny.localdomain> <20050330152208.GB12672@muc.de>
 <20050330153313.GD32111@g5.random>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andi Kleen <ak@muc.de>, jamal <hadi@cyberus.ca>,
        Dmitry Yusupov <dmitry_yus@yahoo.com>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        mpm@selenic.com, michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
        ksummit-2005-discuss@thunk.org, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrea Arcangeli <andrea@suse.de>
In-Reply-To: <20050330153313.GD32111@g5.random>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 30 Mar 2005, Andrea Arcangeli wrote:

> You can be right the receive path may be less of a pratical issue, but
> it's still very much an at least theoretical source of deadlock.

Oh, but this deadlock has been seen in practice.  When the
system is very low on memory, kswapd will keep allocating
memory to write things out, all the way down to 0 free pages.

Then there will be no memory left for GFP_ATOMIC allocations.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
