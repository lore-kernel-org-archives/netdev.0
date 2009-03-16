From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: [PATCH 2/2] r8169: revert "r8169: read MAC address from EEPROM on
	init (2nd attempt)"
Date: Mon, 16 Mar 2009 01:53:01 +0100
Message-ID: <18877.41709.567947.25614@pilspetsen.it.uu.se>
References: <20090315111050.GB17800@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Dave Jones <davej@redhat.com>,
	Mikael Pettersson <mikpe@it.uu.se>,
	Tim Durack <tdurack@gmail.com>, ivecera@redhat.com,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aun.it.uu.se ([130.238.12.36]:41975 "EHLO aun.it.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753515AbZCPAxa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2009 20:53:30 -0400
In-Reply-To: <20090315111050.GB17800@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu writes:
 > It fails on the following systems:
 > - RTL8169sc/8110sc (XID 18000000)
 >   reported by Tim Durack <tdurack@gmail.com> (x86)
 > - RTL8169sb/8110sb (XID 10000000)
 >   reported by Mikael Pettersson <mikpe@it.uu.se> (ARM)
 > 
 > The patch appeared to work on x86 for the following systems:
 > RTL8169sb/8110sb 10000000 PCI   (EXT)
 > RTL8110s         04000000 PCI   (EXT)
 > RTL8102e         24a00000 PCI-E (LOM)
 > RTL8168c/8111c   3c2000c0 PCI-E (LOM)
 > RTL8168b/8111b   38000000 PCI-E (LOM)
 > RTL8168b/8111b   38000000 PCI-E (EXT)
 > 
 > The patch exposes two problems:
 > 1) while not completely wrong, mac addresses are not read correctly
 >    from the EEPROM
 > 2) the MAC address registers are not correctly set
 > 
 > Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Thanks. With these two patches applied 2.6.29-rc8 now works fine
with the r8169 in my NAS box.

Tested-by: Mikael Pettersson <mikpe@it.uu.se>
