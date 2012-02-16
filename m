From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v8 5/8] seccomp: Add SECCOMP_RET_TRAP
Date: Thu, 16 Feb 2012 13:28:32 -0800
Message-ID: <4F3D7500.2070604@zytor.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org> <1329422549-16407-5-git-send-email-wad@chromium.org> <CAE6n16mCrJC=Sre+PT1H_VfSjW0MGyi0xtEcdcRvGMvvwXWzmA@mail.gmail.com> <CABqD9hZSLqn+=jr6sWwp_eJ5WsuGpH2Khoc_7aRmYt+1ZaEGoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Markus Gutschke <markus@chromium.org>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, mingo@redhat.com, oleg@redhat.com,
	peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
	tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, eric.dumazet@gmail.com, keescook@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CABqD9hZSLqn+=jr6sWwp_eJ5WsuGpH2Khoc_7aRmYt+1ZaEGoA@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/16/2012 12:42 PM, Will Drewry wrote:
> On Thu, Feb 16, 2012 at 2:24 PM, Markus Gutschke <markus@chromium.org> wrote:
>> SIGTRAP might not be the ideal choice of signal number, as it can make it
>> very difficult to debug the program in gdb.
> 
> True enough.  In theory, we could use the lower 16-bits of the return
> value to let the bpf program set a signal, but not all signals are
> masked synchronous and those that are probably get gdb's attention,
> just not a severely :) (ILL, SEGV, BUS, TRAP, FPE). Perhaps SIGILL is
> a logically appropriate option -- or letting the api user decide from
> the SYNCHRONOUS_MASK set.  I'm open to whatever makes sense, though.
> (I wasn't even sure if it was kosher to add a new TRAP_SECCOMP value.)
> 

There is a standard signal for this -- SIGSYS -- which happens to be
currently unused in Linux.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

