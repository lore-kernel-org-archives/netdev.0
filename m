From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: Sysctl syscall
Date: Wed, 15 Nov 2006 23:19:18 +0100 (MET)
Message-ID: <Pine.LNX.4.61.0611152317120.12683@yvahk01.tjqt.qr>
References: <200611160003.02681.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailer.gwdg.de ([134.76.10.24]:59575 "EHLO emailer.gwdg.de")
	by vger.kernel.org with ESMTP id S1161977AbWKOWUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 17:20:04 -0500
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200611160003.02681.hasso@estpak.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Nov 16 2006 00:03, Hasso Tepper wrote:
>
>Compiling the program which uses a lot "sysctl" syscalls, gives me this 
>warning on Debian unstable:
>
>"warning: the `sysctl' syscall has been removed from 2.6.18+ kernels, 
>direct access to `/proc/sys' should be used instead."
>
>Is it true?

Well it was unobsoleted in 2.6.19 if I followed the list correctly.

>And what can be used as alternative which would work with both 
>2.4 and 2.6 kernels
>and would work with capabilities (sys/capability.h)?
>Accessing `/proc/sys' directly isn't such alternative as it doesn't work 
>with capabilities.



	-`J'
-- 
