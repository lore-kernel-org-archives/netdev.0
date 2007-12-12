From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [2.6 patch] drivers/net/sis190.c section fix
Date: Wed, 12 Dec 2007 23:56:30 +0100
Message-ID: <20071212225630.GA15947@electric-eye.fr.zoreil.com>
References: <20071211222356.GA14204@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759434AbXLLXDx@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071211222356.GA14204@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk <bunk@kernel.org> :
> This patch fixes the following section mismatch with CONFIG_HOTPLUG=n:
[...]
> WARNING: vmlinux.o(.init.text.20+0x4cb25): Section mismatch: reference to .exit.text:sis190_mii_remove (between 'sis190_init_one' and 'read_eeprom')

Thanks. Applied at:

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git sis190

-- 
Ueimor
