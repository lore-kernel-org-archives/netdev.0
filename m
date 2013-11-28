From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net] r8169: check ALDPS bit and disable it if enabled for
 the 8168g
Date: Thu, 28 Nov 2013 01:02:07 +0100
Message-ID: <20131128000207.GC5342@electric-eye.fr.zoreil.com>
References: <1385538516-32104-1-git-send-email-dchang@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	jlee@suse.com, David Chang <dchang@suse.com>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36856 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757799Ab3K1ACX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 19:02:23 -0500
Content-Disposition: inline
In-Reply-To: <1385538516-32104-1-git-send-email-dchang@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Chang <dchang@suse.com> :
[...]
> Windows driver will enable ALDPS function, but linux driver and firmware
> do not have any configuration related to ALDPS function for 8168g.
> So restart system to linux and remove the NIC cable, LAN enter ALDPS,
> then LAN RX will be disabled.
> 
> This issue can be easily reproduced on dual boot windows and linux
> system with RTL_GIGA_MAC_VER_40 chip.

Hayes, could it be that a different chipset also needs the same kind
of fix ?

-- 
Ueimor
