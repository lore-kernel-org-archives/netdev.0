From: Mark Einon <mark@einon.net>
Subject: Re: [PATCH net-next] et131x: Add PCIe gigabit ethernet driver et131x
 to drivers/net
Date: Wed, 1 Oct 2014 20:02:59 +0100
Message-ID: <20141001190259.GA2697@msilap.einon.net>
References: <1412112586-2194-1-git-send-email-mark.einon@gmail.com>
 <20141001124500.GH3279@distanz.ch>
 <1412171027.3247.6.camel@joe-AO725>
 <20141001141449.GI3279@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, Mark Einon <mark.einon@gmail.com>,
	davem@davemloft.net, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141001141449.GI3279@distanz.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 01, 2014 at 04:14:49PM +0200, Tobias Klauser wrote:
> On 2014-10-01 at 15:43:47 +0200, Joe Perches <joe@perches.com> wrote:
> > On Wed, 2014-10-01 at 14:45 +0200, Tobias Klauser wrote:
> > > On 2014-09-30 at 23:29:46 +0200, Mark Einon <mark.einon@gmail.com> wrote:
> > > > This adds the ethernet driver for Agere et131x devices to
> > > > drivers/net/ethernet.
> > []
> > > > diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
> > []
> > > > +	rc = pci_enable_device(pdev);
> > > > +	if (rc < 0) {
> > > > +		dev_err(&pdev->dev, "pci_enable_device() failed\n");
> > > > +		goto out;
> > > 
> > > Nit: Just return rc here.
> > 
> > I don't think it matters at all.
> 
> Combined with my second remark this change makes the `out' label
> unnecessary. If Mark decides to keep the goto here, at least the
> position of the label should be changed to the end of the function, to
> remain predictable and avoid jumping back.

Hi Tobias, Thanks for the review. Yes, I think it is a bit nit-picking, and I'd
prefer to have just one return in the function. I don't think replacing the
return with a goto adds much and in the interests of keeping churn down, I
won't be making the change unless it prevents the driver moving out of staging.

Cheers,

Mark
