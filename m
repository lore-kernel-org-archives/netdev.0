From: "David S. Miller" <davem@redhat.com>
Subject: Re: Request: Allocate a Netlink Family Number for MPLS
Date: Mon, 1 Dec 2003 12:45:32 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031201124532.3f6b6a65.davem@redhat.com>
References: <Pine.SOL.4.40.0312011518440.25991-100000@gervaise.enst.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ramon Casellas <casellas@infres.enst.fr>
In-Reply-To: <Pine.SOL.4.40.0312011518440.25991-100000@gervaise.enst.fr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Dec 2003 15:36:26 +0100 (MET)
Ramon Casellas <casellas@infres.enst.fr> wrote:

> We're working in porting mpls for linux to 2.6 and one of the planned
> features is to move from an IOCTL based approach to a Netlink based one
> for updating/querying the MPLS FTN/ILM/Label Mapping/... tables from
> userspace. Since netlink families are public, I would
> like to know if it is possible to reserve a family for MPLS, even though
> the MPLS patch is not part of the official kernel.

You don't need a whole new netlink family.  Just create a dummy
address family for MPLS (ie. AF_MPLS) and then just use
NETLINK_ROUTE.
