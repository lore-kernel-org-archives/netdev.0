From: jaganav@us.ibm.com
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics)
Date: Sat,  2 Apr 2005 02:29:51 -0500
Message-ID: <1112426991.424e49ef57e2b@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
        Roland Dreier <roland@topspin.com>, Benjamin LaHaise <bcrl@kvack.org>,
        Dmitry Yusupov <dmitry_yus@yahoo.com>, open-iscsi@googlegroups.com,
        "David  S. Miller" <davem@davemloft.net>, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com, bmt@zurich.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg KH <greg@kroah.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quoting Greg KH <greg@kroah.com>:

> On Fri, Apr 01, 2005 at 09:27:38PM -0800, Greg KH wrote:
> > On Fri, Apr 01, 2005 at 08:37:13PM -0500, jaganav@us.ibm.com wrote:
> > > 
> > > Several RNIC adapter vendors, who contribute to the 
> > > openRDMA effort, are quite willing to opensource 
> > > their drivers through openRDMA project.
> > 
> > "Several"?  Why not all?

Because I haven't heard from 'all' of them yet that they would opensource.
I am sure every vendor will do when the most of the other vendors are
opensourcing it but I can't speak for them. I have asked in the past and will
continue to ask every vendor to opensource their driver and make it part of
openRDMA stack.

> > 
> > And why the dual license?  What good is writing Linux kernel code that
> > is BSD licensed for such a core component?  Didn't you all learn from
> > the openib licensing mess?
> 
> Oh, and for those of you who might not know what mess I am talking
> about:
> 
> The openib code was set up to be dual GPL and BSD licensed for the
> express purpose of taking the openib code and placing it into a closed
> source operating system (not any of the *BSDs).  Needless to say, this
> has prevented me from doing any openib work, and probably the same for a
> number of other Linux kernel developers.
> 

Absolutely understand the dual-license mess with openIB code. -:)
However the intention of dual license with OpenRDMA is not for placing
the code in closed source OSes but specifically for BSD* and in fact, the
request is specifically made by the most adapter vendors as they wanted to offer
the same on BSD platforms as well.

BTW, unlike OpenIB initial stack (i.e. Gen1) which was already developed when it
got opensourced, the openRDMA code is developed from scratch in true opensource
fashion (of course, OpenIB has also followed this approach for their next
generation stack though) with no ifdef code for BSD*.

If this dual license is a concern to other kernel developers as well from
contributing to OpenRDMA, we would seriously consider this and discuss with the
adapter vendors.

Thanks 
Venkat
