From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net, ethernet, LLVMLinux: Add missing
 MODULE_DEVICE_TABLE()
Date: Wed, 28 Jan 2015 22:42:28 -0800 (PST)
Message-ID: <20150128.224228.1533046356464752424.davem@davemloft.net>
References: <1422495374-22835-1-git-send-email-behanw@converseincode.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, ajit.khaparde@emulex.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	subbu.seetharaman@emulex.com, arnd@arndb.de
To: behanw@converseincode.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422495374-22835-1-git-send-email-behanw@converseincode.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Behan Webster <behanw@converseincode.com>
Date: Wed, 28 Jan 2015 17:36:14 -0800

> Missing MODULE_DEVICE_TABLE for pci ids from benet driver found by clang.
> 
> Signed-off-by: Behan Webster <behanw@converseincode.com>
> Suggested-by: Arnd Bergmann <arnd@arndb.de>

Why are you removing the device table?

Second of all, your Subject needs to be adjusted, using "net" and
"LLVMLinux" in your subsystem prefix is not appropriate.  Simply
"be2net: ", the name of this driver, is sufficient.
