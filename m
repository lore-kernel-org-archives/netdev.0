From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Allow group ownership of TUN/TAP devices (fwd)
Date: Mon, 02 Jul 2007 22:50:46 -0700 (PDT)
Message-ID: <20070702.225046.102906247.davem@davemloft.net>
References: <Line.LNX.4.64.0706181216230.8746@localhost.localdomain>
	<20070618.223654.14957392.davem@davemloft.net>
	<20070621145911.GA5874@c2.user-mode-linux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org, agx@sigxcpu.org
To: jdike@addtoit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43499
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752138AbXGCFu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 01:50:27 -0400
In-Reply-To: <20070621145911.GA5874@c2.user-mode-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Dike <jdike@addtoit.com>
Date: Thu, 21 Jun 2007 10:59:11 -0400

> On Mon, Jun 18, 2007 at 10:36:54PM -0700, David Miller wrote:
> > This patch looks fine.
> > 
> > I'd like it resubmitted with a proper changelog and signoff, and once
> > I have that I will thus queue it up for the 2.6.23 merge window.
> 
> Introduce a new syscall TUNSETGROUP for group ownership setting of tap
> devices. The user now is allowed to send packages if either his euid or
> his egid matches the one specified via tunctl (via -u or -g
> respecitvely). If both, gid and uid, are set via tunctl, both have to
> match.
> 
> Signed-Off-By: Guido Guenther <agx@sigxcpu.org>
> Signed-Off-By: Jeff Dike <jdike@linux.intel.com>

Patch applied, thanks a lot!
