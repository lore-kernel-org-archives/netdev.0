From: Rik van Riel <riel@redhat.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
 Topics
Date: Thu, 31 Mar 2005 14:39:01 -0500 (EST)
Message-ID: <Pine.LNX.4.61.0503311438310.8643@chimarrao.boston.redhat.com>
References: <20050331114122.GL24804@muc.de> <20050331193444.GS24804@muc.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alex Aizman <itn780@yahoo.com>, open-iscsi@googlegroups.com,
        "'jamal'" <hadi@cyberus.ca>, "'Dmitry Yusupov'" <dmitry_yus@yahoo.com>,
        "'James Bottomley'" <James.Bottomley@HansenPartnership.com>,
        mpm@selenic.com, michaelc@cs.wisc.edu, ksummit-2005-discuss@thunk.org,
        "'netdev'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050331193444.GS24804@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 31 Mar 2005, Andi Kleen wrote:

> This does not work, because any writable file system can be in theory
> an OOM deadlock and would need to be resource protected. Just someone needs 
> to mmap a file on it and dirty enough pages in it to full up system
> memory and make the system deadlock while trying to clean pages
> to get free memory.

You cannot fill up the mempools with dirty pages, which
makes sure we don't deadlock.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
