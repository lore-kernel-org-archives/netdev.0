From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Fix WoL on RTL8168d/8111d.
Date: Mon, 29 Oct 2012 00:05:23 +0100
Message-ID: <20121028230523.GA26778@electric-eye.fr.zoreil.com>
References: <1351392414-32219-1-git-send-email-kibi@debian.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Cyril Brulebois <kibi@debian.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1351392414-32219-1-git-send-email-kibi@debian.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cyril Brulebois <kibi@debian.org> :
> This regression was spotted between Debian squeeze and Debian wheezy
> kernels (respectively based on 2.6.32 and 3.2). The fix was inspired
> by <http://www.spinics.net/lists/netdev/msg178543.html>, using
> RTL_GIGA_MAC_VER_{25,26} for the RTL8168d/8111d chipset.

If someone experiences problems or has questions about WoL with
Realtek's 816x chipsets, http://marc.info/?t=132079219400004 would
imho be a better reference.

[...]
> Tested on top of a 3.2.23 kernel.

It should still be relevant for current kernel. I'll give it a try.

[...]
> It looks like RTL_GIGA_MAC_VER_{25,26} are kinda supposed to go
> together so I kept both. Florent's testing gave the following results:
>  - RTL_GIGA_MAC_VER_25 only: FAIL.
>  - RTL_GIGA_MAC_VER_26 only: SUCCESS.
>  - RTL_GIGA_MAC_VER_25 + RTL_GIGA_MAC_VER_26: SUCCESS.

I don't understand the VER_25 vs VER_26 difference.

-- 
Ueimor
