From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/2 v2] pch_gbe: Do not abort probe on bad MAC
Date: Thu, 19 Apr 2012 11:41:18 -0700
Message-ID: <20120419184118.GA11880@kroah.com>
References: <1333335645-14413-1-git-send-email-tomoya.rohm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org, Darren Hart <dvhart@linux.intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Alan Cox <alan@linux.intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jon Mason <jdmason@kudzu.us>, netdev@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Joe Perches <joe@perches.com>
To: Tomoya MORINAGA <tomoya.rohm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:59596 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932126Ab2DSSlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 14:41:20 -0400
Content-Disposition: inline
In-Reply-To: <1333335645-14413-1-git-send-email-tomoya.rohm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 02, 2012 at 12:00:44PM +0900, Tomoya MORINAGA wrote:
> If the MAC is invalid or not implemented, do not abort the probe. Issue
> a warning and prevent bringing the interface up until a MAC is set manually
> (via ifconfig $IFACE hw ether $MAC).
> 
> Tested on two platforms, one with a valid MAC, the other without a MAC. The real
> MAC is used if present, the interface fails to come up until the MAC is set on
> the other. They successfully get an IP over DHCP and pass a simple ping and
> login over ssh test.
> 
> This is meant to allow the Inforce SYS940X development board:
> http://www.inforcecomputing.com/SYS940X_ECX.html
> (and others suffering from a missing MAC) to work with the mainline kernel.
> Without this patch, the probe will fail and the interface will not be created,
> preventing the user from configuring the MAC manually.
> 
> This does not make any attempt to address a missing or invalid MAC for the
> pch_phub driver.
> 
> commit: 2b53d07891630dead46d65c8f896955fd3ae0302
> kernel version: 3.0, 3.2

How can you want this in 3.0, when the file this patches is not in the
3.0 kernel tree?

Please be more careful.

greg k-h
