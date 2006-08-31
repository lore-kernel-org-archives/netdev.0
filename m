From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: RTL8136
Date: Thu, 31 Aug 2006 23:05:06 +0200
Message-ID: <20060831210506.GA9463@electric-eye.fr.zoreil.com>
References: <4E5C083B8E%linux@youmustbejoking.demon.co.uk> <20060825190455.GA14812@electric-eye.fr.zoreil.com> <4E5C6C7764%linux@youmustbejoking.demon.co.uk> <4E5CF8AF74%linux@youmustbejoking.demon.co.uk> <20060827214135.GA21464@electric-eye.fr.zoreil.com> <4E5D2F7732%linux@youmustbejoking.demon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:22702 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750816AbWHaVHy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 17:07:54 -0400
To: Darren Salt <linux@youmustbejoking.demon.co.uk>
Content-Disposition: inline
In-Reply-To: <4E5D2F7732%linux@youmustbejoking.demon.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Darren Salt <linux@youmustbejoking.demon.co.uk> :
[...]
> The former. Without that, the connection is persistently re-negotiated
> (though, according to the switch's LEDs, it's fine before the module is
> loaded).

The state of the LEDs at startup is not necessarily significant (it can
come from the eeprom).

I have regenerated a serie which includes a fix with the correct RTL_CFG_2
at http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.18-rc5/r8169 (the git
branch has been updated as well).

Could you use it with mii-tool to collect the state of the mii registers
in the broken state and in the working state ?

-- 
Ueimor
