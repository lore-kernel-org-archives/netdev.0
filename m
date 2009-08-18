From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: add Xilinx emac lite device driver
Date: Tue, 18 Aug 2009 14:04:18 -0700
Message-ID: <20090818140418.347cb8ac@nehalam>
References: <20090818153047.48E42ED8051@mail66-dub.bigfish.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	davem@davemloft.net, John Linn <john.linn@xilinx.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>,
	John Williams <john.williams@petalogix.com>,
	Michal Simek <michal.simek@petalogix.com>,
	Sadanand M <sadanan@xilinx.com>
To: John Linn <john.linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53366 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361AbZHRVEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 17:04:22 -0400
In-Reply-To: <20090818153047.48E42ED8051@mail66-dub.bigfish.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Aug 2009 09:30:41 -0600
John Linn <john.linn@xilinx.com> wrote:

> +/**
> + * xemaclite_enable_interrupts - Enable the interrupts for the EmacLite device
> + * @drvdata:	Pointer to the Emaclite device private data
> + *
> + * This function enables the Tx and Rx interrupts for the Emaclite device along
> + * with the Global Interrupt Enable.
> + */
> +static void xemaclite_enable_interrupts(struct net_local *drvdata)

Docbook format is really a not necessary on local functions that
are only used in the driver.  It is fine if you want to use it, as
long as the file isn't processed by kernel make docs but
the docbook is intended for automatic generation of kernel API manuals.

-- 
