From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [2.6 patch] VIA_VELOCITY must depend on INET
Date: Wed, 20 Jul 2005 12:26:26 +0100
Message-ID: <1121858786.11024.25.camel@localhost.localdomain>
References: <20050719135523.GF5031@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261160AbVGTLEY@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050719135523.GF5031@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Maw, 2005-07-19 at 15:55 +0200, Adrian Bunk wrote:
> VIA_VELOCITY=y and INET=n results in the following compile error:
> 
> <--  snip  -->
> 
> ...
>   LD      .tmp_vmlinux1
> drivers/built-in.o: In function `velocity_register_notifier':
> via-velocity.c:(.text+0x3462c6): undefined reference to `register_inetaddr_notifier'
> drivers/built-in.o: In function `velocity_unregister_notifier':
> via-velocity.c:(.text+0x3462d6): undefined reference to `unregister_inetaddr_notifier'
> make: *** [.tmp_vmlinux1] Error 1

Alternatively you could drop those functions when CONFIG_INET is n as
they are only used for wake on arp
