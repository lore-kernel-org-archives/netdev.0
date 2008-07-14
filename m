From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [Suspend-devel] TAP (and TUN?) devices not working after resume
Date: Mon, 14 Jul 2008 18:12:44 +0200
Message-ID: <200807141812.45264.rjw@sisk.pl>
References: <20080714154720.791f6640@symphony>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: suspend-devel@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	netdev@vger.kernel.org
To: James Le Cuirot <chewi@aura-online.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:44834 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753787AbYGNQKp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 12:10:45 -0400
In-Reply-To: <20080714154720.791f6640@symphony>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 14 of July 2008, James Le Cuirot wrote:
> Hi,

Hi,

> uswsusp works great on my machine except for one thing. I use a TAP
> device for QEMU and after resuming from suspend, it doesn't work
> anymore until I delete it and recreate it. This is rather annoying
> because if I have QEMU open, it means I have to close it before
> recreating the interface and then boot Windows up again. I use OpenVPN
> to create/delete the interface but I think that's all it does. The rest
> is done by the kernel. So I'm guessing something's up with the TUN/TAP
> driver or uswsusp itself. I'm using version 0.8. Sorry if this has
> already been fixed.

This is a kernel problem, adding kernel-related CCs.

Thanks,
Rafael
