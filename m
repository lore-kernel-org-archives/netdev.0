From: "James R. Leu" <jleu@mindspring.com>
Subject: Re: Request: Allocate a Netlink Family Number for MPLS
Date: Fri, 5 Dec 2003 11:35:32 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031205173507.GB2241@mindspring.com>
References: <Pine.SOL.4.40.0312011518440.25991-100000@gervaise.enst.fr> <20031201124532.3f6b6a65.davem@redhat.com>
Reply-To: jleu@mindspring.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ramon Casellas <casellas@infres.enst.fr>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031201124532.3f6b6a65.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Dec 01, 2003 at 12:45:32PM -0800, David S. Miller wrote:
> On Mon, 1 Dec 2003 15:36:26 +0100 (MET)
> Ramon Casellas <casellas@infres.enst.fr> wrote:
> 
> > We're working in porting mpls for linux to 2.6 and one of the planned
> > features is to move from an IOCTL based approach to a Netlink based one
> > for updating/querying the MPLS FTN/ILM/Label Mapping/... tables from
> > userspace. Since netlink families are public, I would
> > like to know if it is possible to reserve a family for MPLS, even though
> > the MPLS patch is not part of the official kernel.
> 
> You don't need a whole new netlink family.  Just create a dummy
> address family for MPLS (ie. AF_MPLS) and then just use
> NETLINK_ROUTE.

Agreed.  One could also use AF_MPLS for applications to register for
data associated with the router alert label.  I suppose one
could also go completly nuts and allow an application to open stream
connection that talks and listens on a specific label, but I think 
that is a bit overboard.

-- 
James R. Leu
jleu@mindspring.com
