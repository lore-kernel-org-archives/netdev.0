From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: modpost warning question
Date: Wed, 25 Jul 2007 17:55:03 +1000
Message-ID: <1185350103.5439.314.camel@localhost.localdomain>
References: <Pine.LNX.4.64.0707250210520.14366@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: sam@ravnborg.org, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54686 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751966AbXGYHzW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 03:55:22 -0400
In-Reply-To: <Pine.LNX.4.64.0707250210520.14366@blarg.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-07-25 at 02:14 -0500, Kumar Gala wrote:
> I'm seeing the following warning:
> 
> WARNING: vmlinux.o(.init.text+0x1acdc): Section mismatch: reference to
> .exit.text:gfar_mdio_exit (between 'gfar_init' and 'gfar_mdio_init')
> 
> I don't understand why its not ok to access .exit.text from .init.text
> 
> The following addresses the issue, however I don't particularly like it:

Because exit.text is removed when compiling built-in

Ben.


