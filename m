From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Sat, 2 Aug 2003 17:28:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030802172807.3d56b4ea.davem@redhat.com>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>
	<20030801154021.GA7696@gtf.org>
	<20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>
	<20030801162536.GA18574@gtf.org>
	<20030802222145.GE22222@parcelfarce.linux.theplanet.co.uk>
	<3F2C3C86.6000202@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F2C3C86.6000202@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 02 Aug 2003 18:34:46 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Matthew Wilcox wrote:
> > +static inline void set_ethtool_ops(struct net_device *dev, struct ethtool_ops *
> > ops)
> > +{
> > +       dev->ethtool_ops = ops;
> > +}
> 
> 
> It needs to be a macro for maximum flexibility.

Yes, and please name it with capitol letters, ie.
SET_ETHTOOL_OPS(), I have no idea why you used
lower-case letters when Jeff and I referred to it
consistently with caps. :-)
