From: Rik van Riel <riel@redhat.com>
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of
 2005 Kernel Summit Proposed Topics)
Date: Tue, 5 Apr 2005 11:04:48 -0400 (EDT)
Message-ID: <Pine.LNX.4.61.0504051104020.16866@chimarrao.boston.redhat.com>
References: <1112426991.424e49ef57e2b@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Greg KH <greg@kroah.com>, Stephen Hemminger <shemminger@osdl.org>,
        Roland Dreier <roland@topspin.com>, Benjamin LaHaise <bcrl@kvack.org>,
        Dmitry Yusupov <dmitry_yus@yahoo.com>, open-iscsi@googlegroups.com,
        "David  S. Miller" <davem@davemloft.net>, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com, bmt@zurich.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jaganav@us.ibm.com
In-Reply-To: <1112426991.424e49ef57e2b@imap.linux.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2 Apr 2005 jaganav@us.ibm.com wrote:

> If this dual license is a concern to other kernel developers as well 
> from contributing to OpenRDMA, we would seriously consider this and 
> discuss with the adapter vendors.

It could be a problem when trying to reuse existing
GPL code, eg. to hook into locking mechanisms.  It
could also be a problem if you touch data structures
that are protected by RCU.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
