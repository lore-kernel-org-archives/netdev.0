From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH RFC 02/10] dpaa_eth: add support for DPAA Ethernet
Date: Mon, 20 Jul 2015 07:57:06 +0000
Message-ID: <1437379026.10831.14.camel@transmode.se>
References: <1427905196-27778-1-git-send-email-madalin.bucur@freescale.com>
	 <1437378870.10831.12.camel@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"madalin.bucur@freescale.com" <madalin.bucur@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437378870.10831.12.camel@transmode.se>
Content-Language: en-US
Content-ID: <52AB016A5E264742BA88C9CBA3200037@transmode.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-07-20 at 09:54 +0200, Joakim Tjernlund wrote:
> On Wed, 2015-04-01 at 19:19 +0300, Madalin Bucur wrote:
> > This introduces the Freescale Data Path Acceleration Architecture
> > (DPAA) Ethernet driver (dpaa_eth) that builds upon the DPAA QMan,
> > BMan, PAMU and FMan drivers to deliver Ethernet connectivity on
> > the Freescale DPAA QorIQ platforms.
> > 
> > Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
> > ---
> ....
> > +	net_dev = alloc_etherdev_mq(sizeof(*priv), DPAA_ETH_TX_QUEUES);
> > +	if (!net_dev) {
> > +		dev_err(dev, "alloc_etherdev_mq() failed\n");
> > +		goto alloc_etherdev_mq_failed;
> > +	}
> > +
> > +	snprintf(net_dev->name, IFNAMSIZ, "fm%d-mac%d",
> > +		 dpa_mac_fman_index_get(pdev),
> > +		 dpa_mac_hw_index_get(pdev));
> 
> Should ethernet drivers dictate interface name in user space nowadays?
> I would prefer if you didn't.
> 
> I am trying these patches on a custom T1042 board using Linux 4.1 but
> I cannot get Fixed PHY to work:
> libphy: PHY fixed-0:00 not found
> fsl_dpa dpaa-ethernet.2 eth2: Could not connect to PHY fixed-0:00
> fsl_dpa dpaa-ethernet.2 eth2: init_phy() = -19
> 
> Not sure what I have missed here, any ideas?

I meant I am using http://git.freescale.com/git/cgit.cgi/ppc/upstream/linux.git/
on top of 4.1

 Jocke
