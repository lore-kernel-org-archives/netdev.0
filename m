From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v2 1/7] arm: put types.h in uapi
Date: Mon, 9 Jan 2017 12:00:04 +0000
Message-ID: <20170109120004.GV14217@n2100.armlinux.org.uk>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
 <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
 <1483695839-18660-2-git-send-email-nicolas.dichtel@6wind.com>
 <1990589.0aJHWbJK4F@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@lists.ozlabs.org, linux-kbuild@vger.kernel.org,
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
        linux-raid@vger.kernel.org, linux-m68k@lists.linux-m68
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <1990589.0aJHWbJK4F@wuerfel>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Mon, Jan 09, 2017 at 12:33:02PM +0100, Arnd Bergmann wrote:
> On Friday, January 6, 2017 10:43:53 AM CET Nicolas Dichtel wrote:
> > 
> > diff --git a/arch/arm/include/asm/types.h b/arch/arm/include/asm/types.h
> > index a53cdb8f068c..c48fee3d7b3b 100644
> > --- a/arch/arm/include/asm/types.h
> > +++ b/arch/arm/include/asm/types.h
> > @@ -1,40 +1,6 @@
> >  #ifndef _ASM_TYPES_H
> >  #define _ASM_TYPES_H
> >  
> > -#include <asm-generic/int-ll64.h>
> ...
> > -#define __UINTPTR_TYPE__       unsigned long
> > -#endif
> > +#include <uapi/asm/types.h>
> >  
> >  #endif /* _ASM_TYPES_H */
> > 
> 
> Moving the file is correct as far as I can tell, but the extra
> #include is not necessary here, as the kernel will automatically
> search both arch/arm/include/ and arch/arm/include/uapi/.

Indeed, I'd like to see the include/asm file gone.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
