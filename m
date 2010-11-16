From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 22962] New: building (e)glibc against
 2.6.37-rc1 headers fails
Date: Tue, 16 Nov 2010 14:33:49 -0800
Message-ID: <20101116143349.2fbb6ed8.akpm@linux-foundation.org>
References: <bug-22962-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: stephan@openelec.tv
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42651 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751444Ab0KPWet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 17:34:49 -0500
In-Reply-To: <bug-22962-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 15 Nov 2010 00:09:33 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=22962
> 
>            Summary: building (e)glibc against 2.6.37-rc1 headers fails
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.37-rc1

hm, thanks for picking this up so early.  It would have been irritating
to let this out in 2.6.37.

>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: stephan@openelec.tv
>         Regression: No
> 
> 
> i have problems building eglibc against the linux-2.6.37-rc1 headers:
> 
> /home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/toolchain/bin/i686-openelec-linux-gnu-gcc
> ../sysdeps/unix/sysv/linux/if_index.c -c -std=gnu99 -fgnu89-inline -O3 -Wall
> -Winline -Wwrite-strings -fexcess-precision=fast -fgraphite-identity
> -floop-block -floop-interchange -floop-strip-mine -fmerge-all-constants
> -fno-stack-protector -fno-unwind-tables -ftree-loop-distribution -g -m32
> -march=pentium-m -pipe -s -Wstrict-prototypes -mpreferred-stack-boundary=2
> -fomit-frame-pointer -Wa,-mtune=i686    -I../include
> -I/home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/eglibc-2.12-12025/objdir-eglibc/inet
> -I/home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/eglibc-2.12-12025/objdir-eglibc
> -I../sysdeps/i386/elf -I../nptl/sysdeps/unix/sysv/linux/i386/i686
> -I../sysdeps/unix/sysv/linux/i386/i686 -I../nptl/sysdeps/unix/sysv/linux/i386
> -I../sysdeps/unix/sysv/linux/i386 -I../nptl/sysdeps/unix/sysv/linux
> -I../nptl/sysdeps/pthread -I../sysdeps/pthread
> -I../ports/sysdeps/unix/sysv/linux -I../sysdeps/unix/sysv/linux
> -I../sysdeps/gnu -I../sysdeps/unix/common -I../sysdeps/unix/mman
> -I../sysdeps/unix/inet -I../ports/sysdeps/unix/sysv/i386
> -I../sysdeps/unix/sysv/i386 -I../nptl/sysdeps/unix/sysv
> -I../ports/sysdeps/unix/sysv -I../sysdeps/unix/sysv -I../sysdeps/unix/i386
> -I../nptl/sysdeps/unix -I../ports/sysdeps/unix -I../sysdeps/unix
> -I../sysdeps/posix -I../sysdeps/i386/i686/fpu -I../sysdeps/i386/i686/multiarch
> -I../nptl/sysdeps/i386/i686 -I../sysdeps/i386/i686 -I../sysdeps/i386/i486
> -I../nptl/sysdeps/i386/i486 -I../sysdeps/i386/fpu -I../nptl/sysdeps/i386
> -I../sysdeps/i386 -I../sysdeps/wordsize-32 -I../sysdeps/ieee754/ldbl-96
> -I../sysdeps/ieee754/dbl-64 -I../sysdeps/ieee754/flt-32 -I../sysdeps/ieee754
> -I../sysdeps/generic/elf -I../sysdeps/generic -I../nptl -I../ports  -I..
> -I../libio -I. -nostdinc -isystem
> /home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/toolchain/lib/gcc/i686-openelec-linux-gnu/4.5.1/include
> -isystem
> /home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/toolchain/lib/gcc/i686-openelec-linux-gnu/4.5.1/include-fixed
> -isystem
> /home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/toolchain/i686-openelec-linux-gnu/sysroot/usr/include
> -D_LIBC_REENTRANT -include ../include/libc-symbols.h       -o
> /home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/eglibc-2.12-12025/objdir-eglibc/inet/if_index.o
> -MD -MP -MF
> /home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/eglibc-2.12-12025/objdir-eglibc/inet/if_index.o.dt
> -MT
> /home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/eglibc-2.12-12025/objdir-eglibc/inet/if_index.o 
> In file included from
> /home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/toolchain/i686-openelec-linux-gnu/sysroot/usr/include/linux/netdevice.h:28:0,
>                  from
> /home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/toolchain/i686-openelec-linux-gnu/sysroot/usr/include/linux/rtnetlink.h:9,
>                  from ../sysdeps/unix/sysv/linux/netlinkaccess.h:24,
>                  from ../sysdeps/unix/sysv/linux/if_index.c:33:
> /home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/toolchain/i686-openelec-linux-gnu/sysroot/usr/include/linux/if.h:135:8:
> error: redefinition of 'struct ifmap'
> ../sysdeps/gnu/net/if.h:112:8: note: originally defined here
> /home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/toolchain/i686-openelec-linux-gnu/sysroot/usr/include/linux/if.h:169:8:
> error: redefinition of 'struct ifreq'
> ../sysdeps/gnu/net/if.h:127:8: note: originally defined here
> /home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/toolchain/i686-openelec-linux-gnu/sysroot/usr/include/linux/if.h:218:8:
> error: redefinition of 'struct ifconf'
> ../sysdeps/gnu/net/if.h:177:8: note: originally defined here
> make[3]: ***
> [/home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/eglibc-2.12-12025/objdir-eglibc/inet/if_index.o]
> Error 1
> make[3]: Leaving directory
> `/home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/eglibc-2.12-12025/inet'
> make[2]: *** [inet/subdir_lib] Error 2
> make[2]: Leaving directory
> `/home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/eglibc-2.12-12025'
> make[1]: *** [all] Error 2
> make[1]: Leaving directory
> `/home/stephan/projects/openelec/build.OpenELEC-ATV.i386.devel/eglibc-2.12-12025/objdir-eglibc'
> make: *** [squashfs] Fehler 2
> 
> it seems because of an change in include/linux/rtnetlink.h (commit
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=24824a09e35402b8d58dcc5be803a5ad3937bdba)
> where linux/netdevice.h will be included now linux/if.h together with net/if.h
> will be included - see also comments here:
> http://www.mail-archive.com/ubuntu-bugs@lists.ubuntu.com/msg2611725.html
> 

Maybe we need some __KERNEL__ guards in if.h.

