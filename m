From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v8 3/8] seccomp: add system call filtering using BPF
Date: Thu, 16 Feb 2012 12:06:35 -0800
Message-ID: <4F3D61CB.2000301@zytor.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org> <1329422549-16407-3-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.org,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, mingo@redhat.com, oleg@redhat.com,
	peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
	tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	keescook@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1329422549-16407-3-git-send-email-wad@chromium.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/16/2012 12:02 PM, Will Drewry wrote:
> +
> +/* Format of the data the BPF program executes over. */
> +struct seccomp_data {
> +	int nr;
> +	__u32 __reserved[3];
> +	struct {
> +		__u32	lo;
> +		__u32	hi;
> +	} instruction_pointer;
> +	__u32 lo32[6];
> +	__u32 hi32[6];
> +};
>  

This seems more than a bit odd, no?

	-hpa


-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.
