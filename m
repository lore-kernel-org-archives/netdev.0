From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] et131x: Add PCIe gigabit ethernet driver
 et131x to drivers/net
Date: Wed, 01 Oct 2014 06:43:47 -0700
Message-ID: <1412171027.3247.6.camel@joe-AO725>
References: <1412112586-2194-1-git-send-email-mark.einon@gmail.com>
	 <20141001124500.GH3279@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Mark Einon <mark.einon@gmail.com>, davem@davemloft.net,
	gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141001124500.GH3279@distanz.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-10-01 at 14:45 +0200, Tobias Klauser wrote:
> On 2014-09-30 at 23:29:46 +0200, Mark Einon <mark.einon@gmail.com> wrote:
> > This adds the ethernet driver for Agere et131x devices to
> > drivers/net/ethernet.
[]
> > diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
[]
> > +	rc = pci_enable_device(pdev);
> > +	if (rc < 0) {
> > +		dev_err(&pdev->dev, "pci_enable_device() failed\n");
> > +		goto out;
> 
> Nit: Just return rc here.

I don't think it matters at all.

It's a predictable style to use common exit blocks.

It's a maintainer's right to do it in whatever
fashion is desired.
