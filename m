From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH?] Fix sniffing of ARP replies
Date: Thu, 16 Oct 2003 15:41:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1066344060.2232.9.camel@localhost.localdomain>
References: <32A9D366A0B@vcnet.vc.cvut.cz>
	 <20031016152136.50e2a389.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Petr Vandrovec <VANDROVE@vc.cvut.cz>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David S Miller <davem@redhat.com>
In-Reply-To: <20031016152136.50e2a389.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-10-16 at 15:21, David S. Miller wrote:
> On Thu, 16 Oct 2003 12:07:23 +0200
> "Petr Vandrovec" <VANDROVE@vc.cvut.cz> wrote:
> 
> > It behaves same way it behaved. But recently you renamed packet_type.data
> > to packet_type.af_packet_priv, saying that af_packet_priv should be used
> > only by AF_PACKET code, by nobody else. So I trusted you, removed
> > packet_type.data (and packet_type.af_packet_priv) references from the
> > code - and things stopped working, as with af_packet_priv==NULL ARP
> > replies are not delivered to the registered packet_type callback, as
> > these packets match skb->sk == pt->af_packet_priv for af_packet_priv == NULL.
> 
> vmware was trying to influence the behavior of input packet
> delivery by setting ->data in a way which was never defined.
> That facility existed and continues to exist for the sake
> of AF_PACKET solely, what vmware was doing just happened to work.

vmware wasn't just trying to influence, it used the implementation.

So tell me, where was this definition again?

If it was just how the code functioned, you have no basis for that
argument.  If you have commentary, design docs or even externally
published discussions, that's a different story.  I diddn't find any.

Code is code, readable or intentionally obscured.
Function is function.

Peter's code worked before, it stopped working
after the packet.h/PKT_CAN_SHARE_SKB removal.

You can change the implementation, but your argument is made hollow
by not having any docs.
