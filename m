From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of
 2005 Kernel Summit Proposed Topics)
Date: Fri, 1 Apr 2005 15:43:48 -0800
Message-ID: <20050401154348.553f3c46@dxpl.pdx.osdl.net>
References: <1112321619.424cae539e75e@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@topspin.com>, Benjamin LaHaise <bcrl@kvack.org>,
        Dmitry Yusupov <dmitry_yus@yahoo.com>, open-iscsi@googlegroups.com,
        "David
 S. Miller" <davem@davemloft.net>, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com, bmt@zurich.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jaganav@us.ibm.com
In-Reply-To: <1112321619.424cae539e75e@imap.linux.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 31 Mar 2005 21:13:39 -0500
jaganav@us.ibm.com wrote:

> Quoting Roland Dreier <roland@topspin.com>:
> > I have to admit I don't know much about the TOE / RDMA/TCP / RNIC (or
> > whatever you want to call it) world.  However I know that the large
> > majority of InfiniBand use right now is running on Linux, and I hope
> > the Linux community is willing to work with the IB community.
> >
> 
> Just want to let everyone know know that we have started an opensource
> effort (www.openrdma.org) for enablement of RNICs (RDMA enabled NICs). This
> community has now come up with an architecture
> (http://rdma.sourceforge.net/architecture.pdf) to build this support in Linux.
> Would really appreciate if you review and provide any comments. We have just
> started to hack but no code is available on this project yet.
> 
> Thanks
> Venkat

OpenRdma is a misnomer, because as I read your architecture you are trying to
create a "kernel abstraction layer" for closed source vendor RDMA drivers. This will
never be accepted,  please go back to the drawing board and figure out how to make
real open source drivers.
