From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: commit 0bdb0bd0 breaks shutdown/reboot
Date: Mon, 7 Nov 2011 08:45:40 -0800
Message-ID: <20111107084540.7ffc913f@nehalam.linuxnetplumber.net>
References: <20111107153119.GA11724@comet.dominikbrodowski.net>
	<20111107081316.2e1cc2cb@nehalam.linuxnetplumber.net>
	<20111107163227.GA17798@isilmar-3.linta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38078 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754911Ab1KGQpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 11:45:42 -0500
In-Reply-To: <20111107163227.GA17798@isilmar-3.linta.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Nov 2011 17:32:27 +0100
Dominik Brodowski <linux@dominikbrodowski.net> wrote:

> On Mon, Nov 07, 2011 at 08:13:16AM -0800, Stephen Hemminger wrote:
> > Does this help?
> 
> Unfortunately, no. Reboots still fail.
> 
> > 
> > Subject: sky2: block irq's on down
> > 
> > Need to block IRQ's from phy changes to prevent stray IRQ's when
> > device is down.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Thanks anyway,
> 	Dominik

Are you using Wake On Lan?
