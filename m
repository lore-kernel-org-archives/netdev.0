From: James Morris <jmorris@intercode.com.au>
Subject: Re: [ANNOUNCE] NF-HIPAC: High Performance Packet Classification for
 Netfilter
Date: Fri, 27 Sep 2002 01:27:41 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0209270122570.12511-100000@blackbird.intercode.com.au>
References: <20020925.224001.99456805.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rusty Russell <rusty@rustcorp.com.au>, <nf@hipac.org>,
   <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020925.224001.99456805.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Sep 2002, David S. Miller wrote:

> If you have things that must happen in a sequence to flow through
> your path properly, that's where the "stackable" bit comes in.  You
> do that one bit, skb->dst = dst_pop(skb->dst), then your caller
> will pass the packet on to skb->dst->{output,input}().
> 
> Is it clearer now the kind of things you'll be able to do?
> 

So, this could be used for generic network layer encapsulation, and be 
used for GRE tunnels, SIT etc. without the kinds of kludges currently in 
use?  Sounds nice.


- James
-- 
James Morris
<jmorris@intercode.com.au>
