From: Jon Mason <jon.mason@intel.com>
Subject: Re: [RFC v2 2/2] net: Add support for NTB virtual ethernet device
Date: Mon, 30 Jul 2012 11:19:11 -0700
Message-ID: <20120730181910.GB987@jonmason-lab>
References: <1343607994-32415-1-git-send-email-jon.mason@intel.com>
 <1343607994-32415-3-git-send-email-jon.mason@intel.com>
 <20120730140216.GA1550@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120730140216.GA1550@minipsycho.orion>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 30, 2012 at 04:02:16PM +0200, Jiri Pirko wrote:
> Mon, Jul 30, 2012 at 02:26:34AM CEST, jon.mason@intel.com wrote:
> >+static int __devinit ntb_netdev_probe(struct pci_dev *pdev)
> >+{
> >+	struct net_device *ndev;
> >+	struct ntb_netdev *dev;
> >+	int rc;
> >+
> >+	ndev = alloc_etherdev(sizeof(struct ntb_netdev));
> >+	if (!ndev)
> >+		return -ENOMEM;
> >+
> >+	dev = netdev_priv(ndev);
> >+	dev->ndev = ndev;
> >+	dev->pdev = pdev;
> >+	BUG_ON(!dev->pdev);
> >+	ndev->features = NETIF_F_HIGHDMA;
> >+
> >+	//ndev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
> 	^^ I guess you forgot to un-comment this.

Oops.  An easy fix.  Anything else?

Thanks,
Jon
