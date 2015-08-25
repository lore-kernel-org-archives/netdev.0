From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC, RFT PATCH 1/2] dl2k: Add support for IP1000A-based cards
Date: Wed, 26 Aug 2015 01:08:02 +0200
Message-ID: <20150825230802.GB24297@electric-eye.fr.zoreil.com>
References: <1440363988-12325-1-git-send-email-linux@rainbow-software.org>
 <20150825.140430.663421843230467362.davem@davemloft.net>
 <201508252326.13784.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201508252326.13784.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ondrej Zary <linux@rainbow-software.org> :
[...]
> Actually, gigabit works with this patch. The "PHY magic" part contains 
> mii_write(9, 0x0700) which makes gigabit work.

It'd be extatic if you could set mii->supports_gmii for the appropriate
PHY so that dl2k.c::rio_get_settings returns sensible gigabit status
(note: neither ipg.c nor dl2k.c currently does).

-- 
Ueimor
