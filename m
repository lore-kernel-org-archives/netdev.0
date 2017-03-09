From: Borislav Petkov <bp@suse.de>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Thu, 9 Mar 2017 23:07:32 +0100
Message-ID: <20170309220732.ufqoqlawktsi2gao@pd.tnic>
References: <58C152F1.9090004@iogearbox.net>
 <alpine.DEB.2.20.1703091409080.3521@nanos>
 <58C157E6.1010909@iogearbox.net>
 <alpine.DEB.2.20.1703091547460.3521@nanos>
 <58C19607.6000605@iogearbox.net>
 <CA+55aFyxM--wyvxXGhBOqdJHcdC_kKvGYpv-C5SpYvRNkbEmGw@mail.gmail.com>
 <CA+55aFyu-LHqMaZBaa7VNamxhUR99F4Xr+nL9esLDUBhotopVg@mail.gmail.com>
 <58C19F67.3040509@iogearbox.net>
 <58C1C9DC.7070509@iogearbox.net>
 <20170309215547.jmdzznlkzaxwu2pf@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Kees Cook <keescook@chromium.org>,
        Laura Abbott <labbott@redhat.com>,
        Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        ast@fb.com, the arch/x86 maintainers <x86@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170309215547.jmdzznlkzaxwu2pf@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 09, 2017 at 10:55:47PM +0100, Borislav Petkov wrote:
> Can you make that:
> 
> 	setup_clear_cpu_cap(X86_FEATURE_PGE);
> 
> and see if it fixes your issue?

Hmm, in reading the thread a bit more, that might not work. If I see it
correctly, lguest does

 clear_cpu_cap(&boot_cpu_data, X86_FEATURE_PGE);

after the alternatives have run and static_cpu_has() sites have already
been patched so clearing that bit won't bring anything.

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix Imendörffer, Jane Smithard, Graham Norton, HRB 21284 (AG Nürnberg)
-- 
