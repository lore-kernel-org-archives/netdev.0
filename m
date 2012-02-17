From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v8 1/8] sk_run_filter: add support for custom
 load_pointer
Date: Thu, 16 Feb 2012 17:54:48 -0800
Message-ID: <1329443688.15226.16.camel@joe2Laptop>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.org,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, keescook@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1329422549-16407-1-git-send-email-wad@chromium.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-02-16 at 14:02 -0600, Will Drewry wrote:
> This change allows CONFIG_SECCOMP to make use of BPF programs for
> user-controlled system call filtering (as shown in this patch series).
[]
> diff --git a/net/core/filter.c b/net/core/filter.c
[]
> @@ -542,9 +602,35 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
[]
>  		case BPF_S_LD_W_ABS:
> +			MAYBE_USE_LOAD_FN(LD_W_ABS);
>  		case BPF_S_LD_H_ABS:
> +			MAYBE_USE_LOAD_FN(LD_H_ABS);
>  		case BPF_S_LD_B_ABS:
> +			MAYBE_USE_LOAD_FN(LD_B_ABS);

Would be nice to note fallthrough or add break if necessary.
