From: Rik van Riel <riel@redhat.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
 Topics
Date: Wed, 30 Mar 2005 13:42:53 -0500 (EST)
Message-ID: <Pine.LNX.4.61.0503301342050.30163@chimarrao.boston.redhat.com>
References: <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave>
 <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie>
 <1112130512.1077.107.camel@jzny.localdomain>  <20050330152208.GB12672@muc.de>
 <20050330153313.GD32111@g5.random>  <20050330153948.GE12672@muc.de>
 <20050330154418.GE32111@g5.random>  <20050330160255.GG12672@muc.de>
 <20050330161522.GH32111@g5.random> <1112201709.1090.418.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrea Arcangeli <andrea@suse.de>, Andi Kleen <ak@muc.de>,
        Dmitry Yusupov <dmitry_yus@yahoo.com>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        mpm@selenic.com, michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
        ksummit-2005-discuss@thunk.org, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1112201709.1090.418.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 30 Mar 2005, jamal wrote:

> I think you may need to reserve some small amount of buffers per NIC 
> (<= RX DMA ring size) that are used as temporary buffers before the
> decision is made to reassign to the higher priority memory or drop. 

At that point you also know for which of the higher
priority sockets the packet is.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
