From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wanrouter: Remove it and the drivers that depend on it
Date: Tue, 13 Nov 2012 14:44:06 -0500 (EST)
Message-ID: <20121113.144406.1610017702502358739.davem@davemloft.net>
References: <67fe0c5701a8c7cfe06b178cf04b1c5c06592714.1352548454.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rob@landley.net, harryxiyou@gmail.com, jdike@addtoit.com,
	richard@nod.at, linux@arm.linux.org.uk, ralf@linux-mips.org,
	benh@kernel.crashing.org, paulus@samba.org, chris@zankel.net,
	jcmvbkbc@gmail.com, isdn@linux-pingi.de, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	xiyoulinuxkernelgroup@googlegroups.com, linux-kernel@zh-kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org,
	linuxppc-dev@lists.ozlabs.org,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	linux-xtensa@linux-xtensa.org, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <67fe0c5701a8c7cfe06b178cf04b1c5c06592714.1352548454.git.joe@perches.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sat, 10 Nov 2012 06:20:55 -0800

> Remove wanrouter as it's obsolete and has not been updated
> by sangoma since 2.4.3 or so and it's not used anymore.
> 
> Remove obsolete cyclomx drivers.
> Update defconfig files that enable wanrouter.
> Update files that include now deleted wanrouter bits.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

I'm fine with this change, except the arch defconfig bits.

We've been leaving those alone, and letting the arch maintainers
do the updates themselves periodically.

Please resubmit this with those parts removed.

Thanks.
