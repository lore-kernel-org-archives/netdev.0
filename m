From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 temporary failure to read mac from rom
Date: Mon, 20 Oct 2008 22:41:44 +0200
Message-ID: <20081020204144.GA18614@electric-eye.fr.zoreil.com>
References: <200810201506.06382.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ivan Vecera <ivecera@redhat.com>,
	jeff@garzik.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41359 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752870AbYJTUmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 16:42:06 -0400
Content-Disposition: inline
In-Reply-To: <200810201506.06382.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oliver@neukum.org> :
[...]
> with today's git r8169 failed to read MAC from rom
> 
> r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> r8169 0000:06:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
> r8169 0000:06:00.0: setting latency timer to 64
> eth0: RTL8168b/8111b at 0xffffc20000352000, 00:00:00:00:00:00, XID 38000000 IRQ 4346

Yep, I have got one of those here. It should be fixed/papered over by
any of:

http://userweb.kernel.org/~romieu/r8169/2.6.27-git8/20081020

or:

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r8169-fixes

A pull request was sent on 2008/10/16 (well, almost 17).

-- 
Ueimor
