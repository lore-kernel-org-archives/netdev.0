From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 3/7] nios2: put setup.h in uapi
Date: Mon, 09 Jan 2017 12:33:46 +0100
Message-ID: <3162962.COsNxdSb45@wuerfel>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com> <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com> <1483695839-18660-4-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        linux-mips@linux-mips.org, alsa-devel@alsa-project.org,
        linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org,
        airlied@linux.ie, linux-fbdev@vger.kernel.org,
        dri-devel@lists.freedesktop.org, linux-mtd@lists.infradead.org,
        sparclinux@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-s390@vger.kernel.org, linux-am33-list@redhat.com,
        linux-c6x-dev@linux-c6x.org, linux-rdma@vger.kernel.org,
        linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org,
        coreteam@netfilter.org, fcoe-devel@open-fcoe.org,
        xen-devel@lists.xenproject.org, linux-snps-arc@lists.infradead.org,
        linux-media@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp,
        adi-buildroot-devel@lists.sourceforge.net,
        linux-raid@vger.kernel.org, linux-m68k@lists.linux-m68k.org,
        o
To: linuxppc-dev@lists.ozlabs.org, linux-kbuild@vger.kernel.org
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <1483695839-18660-4-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, January 6, 2017 10:43:55 AM CET Nicolas Dichtel wrote:

> diff --git a/arch/nios2/include/uapi/asm/setup.h b/arch/nios2/include/uapi/asm/setup.h
> new file mode 100644
> index 000000000000..8d8285997ba8
> --- /dev/null
> +++ b/arch/nios2/include/uapi/asm/setup.h
> @@ -0,0 +1,6 @@
> +#ifndef _UAPI_ASM_NIOS2_SETUP_H
> +#define _UAPI_ASM_NIOS2_SETUP_H
> +
> +#include <asm-generic/setup.h>
> +
> +#endif /* _UAPI_ASM_NIOS2_SETUP_H */
> 

This one is only a redirect to an asm-generic header, so it can be
removed completely and replaced with a line in the 
arch/nios2/include/uapi/asm/ file:

generic-y += setup.h

	Arnd
