From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6.26-rc9] r8169: Avoid thrashing PCI conf space on
	RTL_GIGA_MAC_VER_20.
Date: Thu, 10 Jul 2008 21:05:08 +0200
Message-ID: <20080710190508.GA18477@electric-eye.fr.zoreil.com>
References: <48760F22.8040208@ingate.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Marcus Sundberg <marcus@ingate.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761974AbYGJTFq@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48760F22.8040208@ingate.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marcus Sundberg <marcus@ingate.com> :
> The magic write to register 0x82 will often cause PCI config space on
> my 8168 (PCI ID 10ec:8168, revision 2. mounted in an LG P300 laptop)
> to be filled with ones during driver load, and thus breaking NIC
> operation until reboot. If it does not happen on first driver load it
> can easily be reproduced by unloading and loading the driver a few
> times.

Nice. Thanks.

[...]
> ---
> The magic write is not present in the r8168 driver from RealTek either.
> Does anyone know what it's supposed to do?

No idea. It is not used in the 8101/8102 driver either.

-- 
Ueimor
