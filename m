From: Richard Farina <sidhayn@gmail.com>
Subject: Re: Can't build alx driver for hardened 3.7 kernel
Date: Fri, 11 Jan 2013 17:50:38 -0500
Message-ID: <50F0973E.9040506@gmail.com>
References: <CANQAqMVMY8Q2B0_2GatohnpBV5cYOY_vNb0owqMfi07ExrtvbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: backports@vger.kernel.org, netdev@vger.kernel.org
To: Norman Shulman <norman.shulman@n-dimension.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:57280 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160Ab3AKWtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 17:49:43 -0500
In-Reply-To: <CANQAqMVMY8Q2B0_2GatohnpBV5cYOY_vNb0owqMfi07ExrtvbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2013 05:37 PM, Norman Shulman wrote:
> nshulman@nvshp:~/src/compat-drivers-2013-01-10-2
> $ uname -a
> Linux nvshp 3.7.0-hardened #4 SMP Wed Jan 9 12:01:45 EST 2013 x86_64
> Intel(R) Core(TM) i7-3770 CPU @ 3.40GHz GenuineIntel GNU/Linux

Looking at that uname I'm guessing gentoo? My team maintains a
compat-drivers ebuild that supports building on hardened. We only do the
stable releases but if it helps, you can find it in the pentoo overlay.

-Zero_Chaos
> 
> nshulman@nvshp:~/src/compat-drivers-2013-01-10-2
> $ ./scripts/driver-select alx
> Processing new driver-select request...
> Backing up makefile: Makefile.bk
> Backup exists: Makefile.bk
> Backing up makefile: drivers/net/ethernet/broadcom/Makefile.bk
> Backing up makefile: drivers/net/ethernet/atheros/Makefile.bk
> Backup exists: Makefile.bk
> Backup exists: Makefile.bk
> Backup exists: drivers/net/ethernet/broadcom/Makefile.bk
> 
> nshulman@nvshp:~/src/compat-drivers-2013-01-10-2
> $ make
> ./scripts/gen-compat-autoconf.sh
> /home/nshulman/src/compat-drivers-2013-01-10-2/.config
> /home/nshulman/src/compat-drivers-2013-01-10-2/config.mk >
> include/linux/compat_autoconf.h
> make -C /lib/modules/3.7.0-hardened/build
> M=/home/nshulman/src/compat-drivers-2013-01-10-2 modules
> make[1]: Entering directory `/usr/src/linux-3.7.0-hardened'
> /home/nshulman/src/compat-drivers-2013-01-10-2/config.mk:73: "WARNING:
> You are running a kernel >= 2.6.23, you should enable in it
> CONFIG_NET_SCHED for 802.11[ne] support"
> /home/nshulman/src/compat-drivers-2013-01-10-2/config.mk:252:
> "WARNING: CONFIG_CFG80211_WEXT will be deactivated or not working
> because kernel was compiled with CONFIG_WIRELESS_EXT=n. Tools using
> wext interface like iwconfig will not work. To activate it build your
> kernel e.g. with CONFIG_LIBIPW=m."
>   CC [M]  /home/nshulman/src/compat-drivers-2013-01-10-2/compat/main.o
>   CC [M]  /home/nshulman/src/compat-drivers-2013-01-10-2/compat/compat-3.8.o
>   CC [M]  /home/nshulman/src/compat-drivers-2013-01-10-2/compat/cordic.o
>   CC [M]  /home/nshulman/src/compat-drivers-2013-01-10-2/compat/crc8.o
>   LD [M]  /home/nshulman/src/compat-drivers-2013-01-10-2/compat/compat.o
> scripts/Makefile.build:44:
> /home/nshulman/src/compat-drivers-2013-01-10-2/drivers/net/ethernet/atheros/alx/Makefile:
> No such file or directory
> make[4]: *** No rule to make target
> `/home/nshulman/src/compat-drivers-2013-01-10-2/drivers/net/ethernet/atheros/alx/Makefile'.
>  Stop.
> 
> 
> --
> Norman Shulman
> Sr. Developer/Architect
> N-Dimension Solutions Inc.
> 9030 Leslie St, Unit 300
> Richmond Hill, ON L4B 1G2
> Canada
> 
> Tel: 905 707-8884 x 226
> Fax: 905 707-0886
> 
> This email and any files transmitted with it are solely intended for
> the use of the named recipient(s) and may contain information that is
> privileged and confidential. If you receive this email in error,
> please immediately notify the sender and delete this message in all
> its forms.
> --
> To unsubscribe from this list: send the line "unsubscribe backports" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
