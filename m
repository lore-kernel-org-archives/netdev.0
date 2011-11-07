From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 0/2] 802.1ad S-VLAN support
Date: Tue, 8 Nov 2011 00:18:13 +0100
Message-ID: <20111107231813.GA29930@electric-eye.fr.zoreil.com>
References: <1320512055-1231037-1-git-send-email-equinox@diac24.net> <1320678704.3020.33.camel@bwh-desktop> <20111107154857.GC1833899@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59165 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150Ab1KGXXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 18:23:22 -0500
Content-Disposition: inline
In-Reply-To: <20111107154857.GC1833899@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Lamparter <equinox@diac24.net> :
[...]
> A nice side-effect would be that we can export this value in sysfs so
> the admin easily can see the hardware limitations. No more trial & error
> to find that r8169 (or was it forcedeth?) has the totally weird value of
> 7200... ("almost-jumbo-frames-but-not-quite")

Pong. This is legacy PCI 8169. 

r8169.c::rtl_chip_infos in current -git summarizes the situation.

It is partly a matter of size : one can't always enable Tx checksum and
jumbo frames at the same time for instance.

-- 
Ueimor
