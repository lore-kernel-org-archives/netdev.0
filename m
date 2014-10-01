From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net-next] et131x: Add PCIe gigabit ethernet driver et131x
 to drivers/net
Date: Wed, 1 Oct 2014 16:14:49 +0200
Message-ID: <20141001141449.GI3279@distanz.ch>
References: <1412112586-2194-1-git-send-email-mark.einon@gmail.com>
 <20141001124500.GH3279@distanz.ch>
 <1412171027.3247.6.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Einon <mark.einon@gmail.com>, davem@davemloft.net,
	gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1412171027.3247.6.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014-10-01 at 15:43:47 +0200, Joe Perches <joe@perches.com> wrote:
> On Wed, 2014-10-01 at 14:45 +0200, Tobias Klauser wrote:
> > On 2014-09-30 at 23:29:46 +0200, Mark Einon <mark.einon@gmail.com> wrote:
> > > This adds the ethernet driver for Agere et131x devices to
> > > drivers/net/ethernet.
> []
> > > diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
> []
> > > +	rc = pci_enable_device(pdev);
> > > +	if (rc < 0) {
> > > +		dev_err(&pdev->dev, "pci_enable_device() failed\n");
> > > +		goto out;
> > 
> > Nit: Just return rc here.
> 
> I don't think it matters at all.

Combined with my second remark this change makes the `out' label
unnecessary. If Mark decides to keep the goto here, at least the
position of the label should be changed to the end of the function, to
remain predictable and avoid jumping back.
