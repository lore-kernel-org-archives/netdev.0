From: "James R. Leu" <jleu@mindspring.com>
Subject: Re: [ANNOUNCE] NF-HIPAC: High Performance Packet Classification for Netfilter
Date: Thu, 26 Sep 2002 11:46:17 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020926114617.C10590@nero.doit.wisc.edu>
References: <20020925.224001.99456805.davem@redhat.com> <Mutt.LNX.4.44.0209270122570.12511-100000@blackbird.intercode.com.au>
Reply-To: jleu@mindspring.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <Mutt.LNX.4.44.0209270122570.12511-100000@blackbird.intercode.com.au>; from jmorris@intercode.com.au on Fri, Sep 27, 2002 at 01:27:41AM +1000
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I missed the original post.  Is there a patch availble for testing?

Jim

On Fri, Sep 27, 2002 at 01:27:41AM +1000, James Morris wrote:
> On Wed, 25 Sep 2002, David S. Miller wrote:
> 
> > If you have things that must happen in a sequence to flow through
> > your path properly, that's where the "stackable" bit comes in.  You
> > do that one bit, skb->dst = dst_pop(skb->dst), then your caller
> > will pass the packet on to skb->dst->{output,input}().
> > 
> > Is it clearer now the kind of things you'll be able to do?
> > 
> 
> So, this could be used for generic network layer encapsulation, and be 
> used for GRE tunnels, SIT etc. without the kinds of kludges currently in 
> use?  Sounds nice.
> 
> 
> - James
> -- 
> James Morris
> <jmorris@intercode.com.au>
> 
> 

-- 
James R. Leu
