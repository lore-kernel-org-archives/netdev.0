From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v18 14/15] x86: Enable HAVE_ARCH_SECCOMP_FILTER
Date: Thu, 12 Apr 2012 15:16:04 -0700
Message-ID: <CAGXu5j+6kWpuNudi_43J1coK-fN5NTrev=ycYSmcbr+dFBJMFg@mail.gmail.com>
References: <1334267284-19166-1-git-send-email-wad@chromium.org>
	<1334267284-19166-14-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-man@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com, jmorris@namei.org
To: Will Drewry <wad@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1334267284-19166-14-git-send-email-wad@chromium.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 12, 2012 at 2:48 PM, Will Drewry <wad@chromium.org> wrote:
> Enable support for seccomp filter on x86:
> - syscall_get_arch()
> - syscall_get_arguments()
> - syscall_rollback()
> - syscall_set_return_value()
> - SIGSYS siginfo_t support
> - secure_computing is called from a ptrace_event()-safe context
> - secure_computing return value is checked (see below).
>
> SECCOMP_RET_TRACE and SECCOMP_RET_TRAP may result in seccomp needing =
to
> skip a system call without killing the process. =A0This is done by
> returning a non-zero (-1) value from secure_computing. =A0This change
> makes x86 respect that return value.
>
> To ensure that minimal kernel code is exposed, a non-zero return valu=
e
> results in an immediate return to user space (with an invalid syscall
> number).
>
> Signed-off-by: Will Drewry <wad@chromium.org>
> Reviewed-by: H. Peter Anvin <hpa@zytor.com>
> Acked-by: Eric Paris <eparis@redhat.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

--=20
Kees Cook
ChromeOS Security
