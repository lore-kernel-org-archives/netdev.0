From: Andi Kleen <ak@muc.de>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: 31 Mar 2005 13:41:22 +0200
Message-ID: <20050331114122.GL24804@muc.de>
References: <20050330161522.GH32111@g5.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: open-iscsi@googlegroups.com, "'jamal'" <hadi@cyberus.ca>,
        "'Dmitry Yusupov'" <dmitry_yus@yahoo.com>,
        "'James Bottomley'" <James.Bottomley@HansenPartnership.com>,
        "'Rik van Riel'" <riel@redhat.com>, mpm@selenic.com,
        michaelc@cs.wisc.edu, ksummit-2005-discuss@thunk.org,
        "'netdev'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Date: Thu, 31 Mar 2005 13:41:22 +0200
To: Alex Aizman <itn780@yahoo.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 30, 2005 at 11:28:07AM -0800, Alex Aizman wrote:
> > Andrea Arcangeli wrote: 
> > 
> > All I care about is to assign a mempool ID to the skb (ID 
> > being unique identifier for the tcp connection I don't care 
> > how the implementation is). 
> 
> It makes sense to provide an API for the NIC driver to allocate skb from the
> *right* mempool. This way if I have plenty of hw rings and/or can allow
> myself a luxury to associate 1-to-1 connection and ring, there's a nice and
> clean memory management model. Even NICs that have only few rings could use
> this - for critical (e.g., storage) connections. 

It wont work - I can guarantee you that if you add a limit like
"we only support 8 iscsi connections max" then users/customers will raise
hell because it does not fit their networks.

-Andi
