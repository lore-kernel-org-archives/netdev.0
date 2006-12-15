From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] netxen: remove private ioctl
Date: Fri, 15 Dec 2006 16:04:33 +0000
Message-ID: <20061215160433.GA18572@infradead.org>
References: <20061205120717.2e362ddf@freekitty> <20061207100903.GA27904@infradead.org> <20061215075708.57a1b6b6@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	"Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:55316 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792AbWLOQEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 11:04:43 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061215075708.57a1b6b6@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 15, 2006 at 07:57:08AM -0800, Stephen Hemminger wrote:
> The netxen driver includes a private ioctl that provides access
> to functionality that is already available in other ways. The PCI
> layer has application access hooks (see setpci), and the statistics
> are available in ethtool/netstats.


ACK. The removed code is full of bugs aswell.

