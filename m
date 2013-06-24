From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next V3 1/3] xen-netback: split event channels
 support for Xen backend driver
Date: Mon, 24 Jun 2013 11:18:07 +0100
Message-ID: <20130624101807.GA2394@zion.uk.xensource.com>
References: <1369240487-18834-1-git-send-email-wei.liu2@citrix.com>
 <1369240487-18834-2-git-send-email-wei.liu2@citrix.com>
 <51C8320902000078000DFF4E@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <david.vrabel@citrix.com>,
	<ian.campbell@citrix.com>, <xen-devel@lists.xen.org>,
	<annie.li@oracle.com>, <konrad.wilk@oracle.com>,
	<netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:37895 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab3FXKch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 06:32:37 -0400
Content-Disposition: inline
In-Reply-To: <51C8320902000078000DFF4E@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 24, 2013 at 10:48:25AM +0100, Jan Beulich wrote:
> >>> On 22.05.13 at 18:34, Wei Liu <wei.liu2@citrix.com> wrote:
> > Netback and netfront only use one event channel to do TX / RX notification,
> > which may cause unnecessary wake-up of processing routines. This patch adds a
> > new feature called feature-split-event-channels to netback, enabling it to
> > handle TX and RX events separately.
> > 
> > Netback will use tx_irq to notify guest for TX completion, rx_irq for RX
> > notification.
> 
> While I can see the benefit for the frontend, does this really make
> a lot of a difference to the backend considering that both rx and tx
> handling get done on the same thread anyway?
> 

Not for now. But I'm working on separating the backend handling routines.

So if you're thinking about backporting, I don't think this is the
material.


Wei.
