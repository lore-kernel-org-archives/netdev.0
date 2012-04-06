From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v17 15/15] Documentation: prctl/seccomp_filter
Date: Fri, 6 Apr 2012 14:26:44 -0700
Message-ID: <20120406142644.223ffff0.akpm@linux-foundation.org>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-16-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org,
 linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
 kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
 x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
 mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
 rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
 luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
 djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
 corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
 coreyb@linux.vnet.ibm.com, keescook@chromium.org, jmorris@namei.org
To: Will Drewry <wad@chromium.org>
Return-path: <kernel-hardening-return-1214-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1333051320-30872-16-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

On Thu, 29 Mar 2012 15:02:00 -0500
Will Drewry <wad@chromium.org> wrote:

> Documents how system call filtering using Berkeley Packet
> Filter programs works and how it may be used.
> Includes an example for x86 and a semi-generic
> example using a macro-based code generator.
> 
>
> ...
>
> +Adding architecture support
> +-----------------------
> +
> +See arch/Kconfig for the authoritative requirements.  In general, if an
> +architecture supports both ptrace_event and seccomp, it will be able to
> +support seccomp filter with minor fixup: SIGSYS support and seccomp return
> +value checking.  Then it must just add CONFIG_HAVE_ARCH_SECCOMP_FILTER
> +to its arch-specific Kconfig.
> diff --git a/samples/Makefile b/samples/Makefile
> index 2f75851..5ef08bb 100644
> --- a/samples/Makefile
> +++ b/samples/Makefile

Oh good, I was going to ask about that.

Can we get this code into tools/testing/selftests?  That way people
will run it more often and it's more likely to be maintained as the
code evolves.
