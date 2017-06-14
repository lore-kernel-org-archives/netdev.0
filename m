From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH v2 0/5] MIPS: Implement eBPF JIT.
Date: Wed, 14 Jun 2017 11:48:58 +0200
Message-ID: <20170614094858.GC31492@linux-mips.org>
References: <20170613222847.7122-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        Markos Chandras <markos.chandras@imgtec.com>,
        Matt Redfearn <matt.redfearn@imgtec.com>
To: David Daney <david.daney@cavium.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20170613222847.7122-1-david.daney@cavium.com>
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

On Tue, Jun 13, 2017 at 03:28:42PM -0700, David Daney wrote:

> Changes in v2:
> 
>   - Squash a couple of the uasm cleanups.
> 
>   - Make insn_table_MM const (suggested by Matt Redfearn)
> 
>   - Put the eBPF in its own source file (should fix build
>     warnings/errors on 32-bit kernel builds).
> 
>   - Use bpf_jit_binary_alloc() (suggested by Daniel Borkmann)
> 
>   - Implement tail calls.
> 
>   - Fix system call tracing to extract arguments for
>     kprobe/__seccomp_filter() tracing (perhaps not really part the the
>     JIT, but necessary to have fun with the samples/bpf programs).
> 
> Most things in samples/bpf work, still working on the incantations to
> build tools/testing/selftests/bpf/ ... 
> 
> 
> >From v1:
> 
> The first three patches improve MIPS uasm in preparation for use by
> the JIT.  Then the eBPF JIT implementation.
> 
> I am CCing netdev@ and the BPF maintainers for their comments, but
> would expect Ralf to merge via the MIPS tree if and when it all looks
> good.

Thanks, applied after fixing a minor conflict in arch/mips/Kconfig.

  Ralf
