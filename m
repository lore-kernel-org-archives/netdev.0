From: Thomas Graf <tgraf@infradead.org>
Subject: Re: the future of ethtool
Date: Tue, 16 Nov 2010 01:25:53 -0500
Message-ID: <20101116062553.GD24292@canuck.infradead.org>
References: <4CE18CEA.5080502@garzik.org>
 <1289852326.2586.32.camel@bwh-desktop>
 <20101115124428.7b857ccb@nehalam>
 <1289855642.2586.38.camel@bwh-desktop>
 <20101115131453.16958d68@nehalam>
 <1289857936.2586.51.camel@bwh-desktop>
 <4CE1B8FD.3000007@garzik.org>
 <20101115233335.GB24292@canuck.infradead.org>
 <1289866230.2586.65.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:39150 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932264Ab0KPGZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 01:25:57 -0500
Content-Disposition: inline
In-Reply-To: <1289866230.2586.65.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 16, 2010 at 12:10:30AM +0000, Ben Hutchings wrote:
> I would expect to treat each operation in a multiple-set as conditional
> on the success of all previous operations.  ethtool or other utilities
> should then take care to put operations in a sensible order (e.g. enable
> TX checksum before TSO, if those remain separate operations).  Error
> reporting in the core is then as simple as reporting how many operations
> were successful plus the error code for the one that failed.

This is already not that trivial with current netlink limitations.
We are pretty much limited to a single int when returning error
states. One more reason to rethink current netlink error semantics.
