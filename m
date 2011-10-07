From: Marc Ballarin <ballarin.marc@gmx.de>
Subject: Regression: non-working WOL with r8169
Date: Fri, 7 Oct 2011 22:19:06 +0200
Message-ID: <20111007221906.810698ba9bf825566a2478bb@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:46456 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753540Ab1JGUTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 16:19:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,
I just bisected a wake-on-lan regression to commit 
92fc43b4159b518f5baae57301f26d770b0834c9 "r8169: modify the flow of the hw reset."

Symptoms: Wake-on-lan does not work, although ethtool reports "Wake-on: g".
Working kernels: 3.0.x or 3.1-rcX with the above commit and all following commits (which
depend on it) reverted (or 3.1-rc with r8169.c from 3.0.x + include fixes)

Hardware is "Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet
controller (rev 06)", (tp->mac_version is 32, i.e RTL_GIGA_MAC_VER_33)

Feel free to ask for any further information.

Regards,
Marc
