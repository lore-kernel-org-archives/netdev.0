From: Matt Wilson <msw@amzn.com>
Subject: Re: [PATCH] net: ena: Add a driver for Amazon Elastic Network
 Adapters (ENA)
Date: Tue, 15 Mar 2016 11:29:33 -0700
Message-ID: <20160315182933.GA754@u54ee753d2d1854bda401.ant.amazon.com>
References: <1458039006-19956-1-git-send-email-netanel@annapurnalabs.com>
 <1458065947.31283.26.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netanel Belgazal <netanel@annapurnalabs.com>,
	zorik@annapurnalabs.com, saeed@annapurnalabs.com,
	alex@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, antoine.tenart@free-electrons.com
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1458065947.31283.26.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 15, 2016 at 01:19:07PM -0500, Dan Williams wrote:
> On Tue, 2016-03-15 at 12:50 +0200, Netanel Belgazal wrote:
> > +
> > +The ENA driver supports industry standard TCP/IP offload features
> > such
> > +as checksum offload and TCP transmit segmentation offload (TSO).
> > +
> > +Receive-side scaling (RSS) is supported for multi-core scaling.
> 
> Any chance it also supports VXLAN offload?

While there's room for tunnel offload fields in the TX/RX descriptors
(e.g., see ena_eth_io_tx_desc), there is no support at this time.

--msw
