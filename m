From: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH v2 7/7] uapi: export all headers under uapi directories
Date: Mon, 9 Jan 2017 12:01:08 +0000
Message-ID: <20170109120107.GW14217@n2100.armlinux.org.uk>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
 <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
 <1483695839-18660-8-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arnd-r2nGTMty4D4@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
        alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, airlied-cv59FeDIM0c@public.gmane.org,
        linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
        linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-am33-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
        fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org,
        linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        uclinux-h8-devel-5NWGOfrQmneRv+LV9MX5uooqe+aC9MnS@public.gmane.org,
        linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, linux-kbuild-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
        linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lin
To: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-metag-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1483695839-18660-8-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-metag-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 06, 2017 at 10:43:59AM +0100, Nicolas Dichtel wrote:
> diff --git a/arch/arm/include/uapi/asm/Kbuild b/arch/arm/include/uapi/asm/Kbuild
> index 46a76cd6acb6..607f702c2d62 100644
> --- a/arch/arm/include/uapi/asm/Kbuild
> +++ b/arch/arm/include/uapi/asm/Kbuild
> @@ -1,23 +1,6 @@
>  # UAPI Header export list
>  include include/uapi/asm-generic/Kbuild.asm
>  
> -header-y += auxvec.h
> -header-y += byteorder.h
> -header-y += fcntl.h
> -header-y += hwcap.h
> -header-y += ioctls.h
> -header-y += kvm_para.h
> -header-y += mman.h
> -header-y += perf_regs.h
> -header-y += posix_types.h
> -header-y += ptrace.h
> -header-y += setup.h
> -header-y += sigcontext.h
> -header-y += signal.h
> -header-y += stat.h
> -header-y += statfs.h
> -header-y += swab.h
> -header-y += unistd.h
>  genhdr-y += unistd-common.h
>  genhdr-y += unistd-oabi.h
>  genhdr-y += unistd-eabi.h

Acked-by: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
