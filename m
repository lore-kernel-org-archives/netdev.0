From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Compile Error with r8169.c
Date: Sat, 24 Jan 2004 22:21:28 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124222128.B2069@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.58.0401241222570.19565@duron.home> <20040124214009.A2069@electric-eye.fr.zoreil.com> <Pine.LNX.4.58.0401241248050.19622@duron.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Lameter <christoph@lameter.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0401241248050.19622@duron.home>; from christoph@lameter.com on Sat, Jan 24, 2004 at 12:49:16PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Lameter <christoph@lameter.com> :
[2.6.2-rc1 expected]
> 2.6.2-rc1

(shitstorm in sight, level 9...)

[...]
> 2.6.2-rc1 right?

Yes (...level 10).

[.config]

No problem here for 'make drivers/net/r8169.o' with this .config at any
stage of patching.

Once r8169-missing-static is applied on top of the other patches, I get:
$ md5sum drivers/net/r8169.c
2525aab3261e165fc5698347eede84f3  drivers/net/r8169.c

(btw, no timer_t at line 383, care to send source file ?)

Before anything is applied (2.4.2-rc1), I get:
$ md5sum drivers/net/r8169.c
4286c8aa2ec99e566b0c43da9a032b14  drivers/net/r8169.c

The top-level Makefile indicates a 2.6.2-rc1 and it just passed correctly
a patch/unpatch of -rc1-mm2.

[...]
> > You can try the first 10 patches (i.e. including r8169-intr_mask.patch)
> > from the last serie.
> 
> I tried them and got the compile failure.

Can you check the md5 sums and issue a simple 'make drivers/net/r8169.o' ?
Here it simply says (KBUILD_VERBOSE=1):
$ make drivers/net/r8169.o
make -f scripts/Makefile.build obj=scripts
make -f scripts/Makefile.build obj=scripts/genksyms
make -f scripts/Makefile.build obj=drivers/net drivers/net/r8169.o
  gcc -Wp,-MD,drivers/net/.r8169.o.d -nostdinc -iwithprefix include -D__KERNEL__ -Iinclude  -D__KERNEL__ -Iinclude  -Wall -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -pipe -mpreferred-stack-boundary=2 -march=athlon -Iinclude/asm-i386/mach-default -O2 -fomit-frame-pointer    -DMODULE -DKBUILD_BASENAME=r8169 -DKBUILD_MODNAME=r8169 -c -o drivers/net/.tmp_r8169.o drivers/net/r8169.c

--
Ueimor
