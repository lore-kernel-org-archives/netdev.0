From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: reproducible kernel freeze using r8169 in Linux 3.0
Date: Sun, 18 Dec 2011 09:32:12 +0100
Message-ID: <20111218083212.GA28286@electric-eye.fr.zoreil.com>
References: <63CE35CA-7DD6-41EC-A745-6BA776D8C5E3@ginzton.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: Matt Ginzton <matt@ginzton.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34321 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628Ab1LRIkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2011 03:40:00 -0500
Content-Disposition: inline
In-Reply-To: <63CE35CA-7DD6-41EC-A745-6BA776D8C5E3@ginzton.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Ginzton <matt@ginzton.net> :
[...]
> Please let me know if I'm reporting this to the right place, or if there's
> any other helpful info I can provide.

Please grep for a XID line in dmesg and send it so we can figure the
specific revision of your chipset (lspci can not figure it).

If it says something like "blah blah XID 1c4...", you should give current
-rc a try (who shouldn't ?).

-- 
Ueimor
