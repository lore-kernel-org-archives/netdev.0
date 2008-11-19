From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 30/33] tg3: convert to net_device_ops
Date: Wed, 19 Nov 2008 13:07:27 -0800
Message-ID: <20081119130727.262ac42a@extreme>
References: <20081117234207.854110282@vyatta.com>
	<20081117234357.345529638@vyatta.com>
	<20081117173706.31960184@extreme>
	<20081119210447.GA26448@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Matt Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57014 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753211AbYKSVHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 16:07:31 -0500
In-Reply-To: <20081119210447.GA26448@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Nov 2008 13:04:47 -0800
"Matt Carlson" <mcarlson@broadcom.com> wrote:

> On Mon, Nov 17, 2008 at 05:37:06PM -0800, Stephen Hemminger wrote:
> > Convert this driver to network device ops.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > ---
> > Handle non-vlan build.
> > 
> > --- a/drivers/net/tg3.c	2008-11-17 17:21:58.000000000 -0800
> > +++ b/drivers/net/tg3.c	2008-11-17 17:26:45.000000000 -0800
> > @@ -13343,6 +13343,24 @@ static void __devinit tg3_init_coal(stru
> >  	}
> >  }
> >  
> > +static const struct net_device_ops tg3_netdev_ops = {
> > +	.open			= tg3_open,
> > +	.stop			= tg3_close,
> 
> One more completely trivial nit.  Is there a reason why you chose
> the verbs to be "open" and "stop" rather than "open" and "close" or
> "start" and "stop"?

Because that is what they were before (but in a different place).
