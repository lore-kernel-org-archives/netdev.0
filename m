From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: Build regressions/improvements in v3.7-rc5
Date: Mon, 12 Nov 2012 22:02:46 +0100
Message-ID: <CAMuHMdXE0yJNivpirGgx08zqLH2086ydeOU6zswXj-+zn8OsWQ@mail.gmail.com>
References: <1352753886-3402-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linuxppc-dev@lists.ozlabs.org, ceph-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352753886-3402-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 12, 2012 at 9:58 PM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> JFYI, when comparing v3.7-rc5 to v3.7-rc4[3], the summaries are:
>   - build errors: +14/-4

14 regressions:
  + drivers/virt/fsl_hypervisor.c: error: 'MSR_GS' undeclared (first
use in this function):  => 799:93
  + error: No rule to make target drivers/scsi/aic7xxx/aicasm/*.[chyl]:  => N/A
  + net/ceph/ceph_common.c: error: dereferencing pointer to incomplete
type:  => 272:13
  + net/ceph/ceph_common.c: error: implicit declaration of function
'request_key' [-Werror=implicit-function-declaration]:  => 249:2
  + net/ceph/crypto.c: error: dereferencing pointer to incomplete
type:  => 463:19, 434:46, 452:5, 448:52, 429:23, 467:36, 447:18
  + net/ceph/crypto.c: error: implicit declaration of function
'key_payload_reserve' [-Werror=implicit-function-declaration]:  =>
437:2
  + net/ceph/crypto.c: error: implicit declaration of function
'register_key_type' [-Werror=implicit-function-declaration]:  => 481:2
  + net/ceph/crypto.c: error: implicit declaration of function
'unregister_key_type' [-Werror=implicit-function-declaration]:  =>
485:2
  + net/ceph/crypto.c: error: unknown field 'destroy' specified in
initializer:  => 477:2
  + net/ceph/crypto.c: error: unknown field 'instantiate' specified in
initializer:  => 475:2
  + net/ceph/crypto.c: error: unknown field 'match' specified in
initializer:  => 476:2
  + net/ceph/crypto.c: error: unknown field 'name' specified in
initializer:  => 474:2
  + net/ceph/crypto.c: error: variable 'key_type_ceph' has initializer
but incomplete type:  => 473:8

powerpc-randconfig

  + error: relocation truncated to fit: R_PPC64_REL24 against symbol
`._mcount' defined in .text section in arch/powerpc/kernel/entry_64.o:
(.text+0x1ff9eb8) => (.text+0x1ffa274), (.text+0x1ff7840)

powerpc-allyesconfig

> [1] http://kisskb.ellerman.id.au/kisskb/head/5614/ (all 117 configs)
> [3] http://kisskb.ellerman.id.au/kisskb/head/5600/ (all 117 configs)

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
