From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 02/03] net/bridge: add support for EtherIP devices
Date: Mon, 25 Sep 2006 07:40:09 -0700
Message-ID: <20060925074009.781a2228@localhost.localdomain>
References: <20060923120704.GA32284@zlug.org>
	<20060923121629.GC32284@zlug.org>
	<20060923210112.130938ca@localhost.localdomain>
	<20060925082445.GB23028@zlug.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:62674 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932207AbWIYOkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 10:40:25 -0400
To: Joerg Roedel <joro-lkml@zlug.org>
In-Reply-To: <20060925082445.GB23028@zlug.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 25 Sep 2006 10:24:45 +0200
Joerg Roedel <joro-lkml@zlug.org> wrote:

> On Sat, Sep 23, 2006 at 09:01:12PM -0700, Stephen Hemminger wrote:
> 
> > If the device looks like a duck (Ethernet), then why does it need
> > a separate ARP type.  There are other tools that might work without
> > modification if it just fully pretended to be an ether device.
> 
> This solves the problem of getting a list of all EtherIP devices. If
> they use ARPHRD_ETHER and use an ioctl in the SIOCDEVPRIVATE space is
> not a save way (not even if the ioctl uses ethip0, this device could be
> owned by another driver if EtherIP is not present).
> On the other hand, a new ARP type opens a lot of new problems. A lot of
> userspace tools and libraries must be changed. So this solutions is not
> perfect.
> 
> Cheers,
> Joerg

To get a list of all EtherIP devices, just maintain a linked list
in the private device information. Use list macros, it isn't hard.
