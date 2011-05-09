From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: future developments of usbnet
Date: Mon, 9 May 2011 11:31:16 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1105091130440.2002-100000@iolanthe.rowland.org>
References: <BANLkTi=AGQyvG58n9FG2Axbz7Ue8a6E3kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Oliver Neukum <oliver@neukum.org>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:37609 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751715Ab1EIPbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 11:31:16 -0400
In-Reply-To: <BANLkTi=AGQyvG58n9FG2Axbz7Ue8a6E3kg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 9 May 2011, Ming Lei wrote:

> Hi,
> 
> 2011/5/9 Oliver Neukum <oliver@neukum.org>:
> 
> > Do we really need to avoid it, or do we just need to recover?
> > If avoidance is needed, should we use NAPI?
> 
> IMO, OOM can recover it certainly but with much cost, so we should
> avoid the case. I don't think NAPI can avoid it, because NAPI will
> cause skb to be allocated without any limit if there are packets
> coming, still no chance left for usbnet_bh to handle and free these
> SKBs.

How do other network drivers handle this problem?  Can the same 
strategy be used?

Alan Stern

