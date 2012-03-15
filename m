From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v15 11/13] ptrace,seccomp: Add PTRACE_SECCOMP support
Date: Thu, 15 Mar 2012 05:49:47 +0100
Message-ID: <d2e03d5f063de84d1bae3c3e06296f81.squirrel@webmail.greenhost.nl>
References: <1331781125-15658-1-git-send-email-wad@chromium.org>
    <1331781125-15658-12-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org, "Will Drewry" <wad@chromium.org>
To: "Will Drewry" <wad@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1331781125-15658-12-git-send-email-wad@chromium.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Will,

On Thu, March 15, 2012 04:12, Will Drewry wrote:
> @@ -73,6 +74,7 @@
>  #define PTRACE_EVENT_VFORK_DONE	5
>  #define PTRACE_EVENT_EXIT	6
>  #define PTRACE_EVENT_STOP	7
> +#define PTRACE_EVENT_SECCOMP	8
>
>  #include <asm/ptrace.h>
>
> @@ -101,8 +103,9 @@
>  #define PT_TRACE_EXEC		PT_EVENT_FLAG(PTRACE_EVENT_EXEC)
>  #define PT_TRACE_VFORK_DONE	PT_EVENT_FLAG(PTRACE_EVENT_VFORK_DONE)
>  #define PT_TRACE_EXIT		PT_EVENT_FLAG(PTRACE_EVENT_EXIT)
> +#define PT_TRACE_SECCOMP	PT_EVENT_FLAG(PTRACE_EVENT_SECCOMP)
>
> -#define PT_TRACE_MASK	0x000003f4
> +#define PT_TRACE_MASK	0x00000ff4

Did you miss this bit?

Greetings,

Indan


