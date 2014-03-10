From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: rfc: checkpatch logical line continuations (was IBM Akebono:
 Add support for a new PHY interface to the IBM emac driver)
Date: Mon, 10 Mar 2014 09:53:41 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6D8E55@AcuExch.aculab.com>
References: <1394077948-8395-1-git-send-email-alistair@popple.id.au>
 <1394077948-8395-3-git-send-email-alistair@popple.id.au>
 <20140307.154142.488351276799532264.davem@davemloft.net>
 <1394226164.16156.96.camel@joe-AO722> <20140307213017.GA18769@cloud>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org" <alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: "'josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org'" <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140307213017.GA18769@cloud>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org
> On Fri, Mar 07, 2014 at 01:02:44PM -0800, Joe Perches wrote:
> > On Fri, 2014-03-07 at 15:41 -0500, David Miller wrote:
> > > From: Alistair Popple <alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org>
> > > Date: Thu,  6 Mar 2014 14:52:25 +1100
> > >
> > > > +	out_be32(dev->reg, in_be32(dev->reg) | WKUP_ETH_RGMIIEN
> > > > +		 | WKUP_ETH_TX_OE | WKUP_ETH_RX_IE);
> > >
> > > When an expression spans multiple lines, the lines should end with
> > > operators rather than begin with them.
> >
> > That's not in CodingStyle currently.
> 
> It's also not even remotely consistent across existing kernel code, and
> it isn't obvious that there's a general developer consensus on the
> "right" way to write it.

My personal preference (which counts for nothing here) is to put
the operators at the start of the continuation like in order to
make it more obvious that it is a continuation.

The netdev rules are particularly problematical for code like:
        if (tst(foo, foo2, foo3, ...) && ....... &&
                tst2(......) && tst3()) {
                baz(....);
where a scan read of the LHS gives the wrong logic.

At least we don't have a coding style that allows very long lnes
an puts } and { on their own lines - leading to:
                ...
        }
        while (foo(...) && bar(...) && ..... /* very long line falls off screen */
        {
                int x;
Is that the top or bottom of a loop?

	David



--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
