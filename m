From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Allow group ownership of TUN/TAP devices (fwd)
Date: Mon, 18 Jun 2007 22:36:54 -0700 (PDT)
Message-ID: <20070618.223654.14957392.davem@davemloft.net>
References: <Line.LNX.4.64.0706181216230.8746@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jdike@addtoit.com
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51114
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752856AbXFSFgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 01:36:35 -0400
In-Reply-To: <Line.LNX.4.64.0706181216230.8746@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Mon, 18 Jun 2007 12:16:31 -0400 (EDT)

> ---------- Forwarded message ----------
> Date: Mon, 18 Jun 2007 12:05:49 -0400
> From: Jeff Dike <jdike@addtoit.com>
> To: maxk@qualcomm.com
> Cc: Guido Guenther <agx@sigxcpu.org>, LKML <linux-kernel@vger.kernel.org>,
>     vtun@office.satix.net
> Subject: [PATCH] Allow group ownership of TUN/TAP devices
> 
> I recieved from Guido Guenther the patch below to the TUN/TAP driver
> which allows group ownerships to be effective.
> 
> It seems reasonable to me.
> 
> > the attached patches allow tun ownership by group. We found this useful
> > since we can then spawn tapX devices on system boot (via
> > /etc/network/interfaces) which logged on users can then use for their
> > virtual machines.
> >   
> > The first patch is for the kernel, the second one for the tunctl. They
> > shouldn't change existing behaviour and we introduced a new syscall for
> > the group setting. The user now is allowed to send packages if either
> > his euid or his egid matches the one specified via tunctl (via -u or -g
> > respecitvely). If both gid and uid are set via tunctl, both have to
> > match. In case you find these useful, please apply.

This patch looks fine.

I'd like it resubmitted with a proper changelog and signoff, and once
I have that I will thus queue it up for the 2.6.23 merge window.

Thanks!
