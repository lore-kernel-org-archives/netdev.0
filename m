From: Andi Kleen <ak@muc.de>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: 31 Mar 2005 20:59:54 +0200
Message-ID: <20050331185954.GR24804@muc.de>
References: <20050330161522.GH32111@g5.random> <20050331114122.GL24804@muc.de> <Pine.LNX.4.61.0503310711430.21935@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alex Aizman <itn780@yahoo.com>, open-iscsi@googlegroups.com,
        "'jamal'" <hadi@cyberus.ca>, "'Dmitry Yusupov'" <dmitry_yus@yahoo.com>,
        "'James Bottomley'" <James.Bottomley@HansenPartnership.com>,
        mpm@selenic.com, michaelc@cs.wisc.edu, ksummit-2005-discuss@thunk.org,
        "'netdev'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Date: Thu, 31 Mar 2005 20:59:54 +0200
To: Rik van Riel <riel@redhat.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0503310711430.21935@chimarrao.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 31, 2005 at 07:12:22AM -0500, Rik van Riel wrote:
> On Thu, 31 Mar 2005, Andi Kleen wrote:
> 
> > It wont work - I can guarantee you that if you add a limit like
> > "we only support 8 iscsi connections max" then users/customers will raise
> > hell because it does not fit their networks.
> 
> What would prevent the iscsi driver from telling the network
> stack to increase the size of the mempools when additional
> iscsi connections are configured ?

I was talking about the hardware limits for early filtering,
not the size of the mempools.

All hardware I found so far has small limits like this.

-Andi
