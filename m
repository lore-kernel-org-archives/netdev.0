From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: commit 0bdb0bd0 breaks shutdown/reboot
Date: Mon, 7 Nov 2011 18:08:14 +0100
Message-ID: <20111107170814.GA7657@comet.dominikbrodowski.net>
References: <20111107153119.GA11724@comet.dominikbrodowski.net>
 <20111107081316.2e1cc2cb@nehalam.linuxnetplumber.net>
 <20111107163227.GA17798@isilmar-3.linta.de>
 <20111107084540.7ffc913f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar-3.linta.de ([188.40.101.200]:51036 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752932Ab1KGRJR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 12:09:17 -0500
Content-Disposition: inline
In-Reply-To: <20111107084540.7ffc913f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 07, 2011 at 08:45:40AM -0800, Stephen Hemminger wrote:
> On Mon, 7 Nov 2011 17:32:27 +0100
> Dominik Brodowski <linux@dominikbrodowski.net> wrote:
> 
> > On Mon, Nov 07, 2011 at 08:13:16AM -0800, Stephen Hemminger wrote:
> > > Does this help?
> > 
> > Unfortunately, no. Reboots still fail.
> > 
> > > 
> > > Subject: sky2: block irq's on down
> > > 
> > > Need to block IRQ's from phy changes to prevent stray IRQ's when
> > > device is down.
> > > 
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > Thanks anyway,
> > 	Dominik
> 
> Are you using Wake On Lan?

Not that I'm aware of. Explicitly disabling WOL by

	$ ethtool -s eth0 wol d

does not help, though.

Best,
	Dominik
