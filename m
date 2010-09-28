From: Alexander Clouter <alex@digriz.org.uk>
Subject: Re: [RFC] Online firmware upgrade in non-embedded systems
Date: Tue, 28 Sep 2010 19:45:33 +0100
Message-ID: <dnp9n7-puv.ln1@chipmunk.wormnet.eu>
References: <1285696787.2282.45.camel@achroite.uk.solarflarecom.com>
Cc: netdev@vger.kernel.org, linux-mtd@lists.infradead.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In gmane.linux.kernel Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> Currently the sfc network driver is optionally combined with an MTD
> driver (CONFIG_SFC_MTD) which exposes all upgradable firmware and
> configuration partitions in flash.  This works nicely in kernels with
> MTD enabled, but since MTD is mainly used in embedded systems with
> on-board flash it is often disabled in distribution kernels and custom
> kernels alike.  This leaves users of sfc unable to upgrade firmware
> without rebuilding the kernel or booting some other distribution.  The
> lack of widespread MTD support is a regular cause of support requests.
> 
----
ac56@proxy0:~$ uname -a
Linux proxy0 2.6.32-5-686 #1 SMP Wed Aug 25 14:28:12 UTC 2010 i686 GNU/Linux
ac56@proxy0:~$ cat /etc/debian_version 
squeeze/sid
ac56@proxy0:~$ grep CONFIG_SFC_MTD /boot/config-2.6.32-5-686 
CONFIG_SFC_MTD=y
ac56@proxy0:~$ grep '^CONFIG_MTD' /boot/config-2.6.32-5-686 | wc
     72      72    1693
----

I tell them "use a real distribution".

Cheers

-- 
Alexander Clouter
.sigmonster says: BOFH excuse #119:
                  evil hackers from Serbia.
