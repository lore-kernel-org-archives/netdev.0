From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v8 3/8] seccomp: add system call filtering using BPF
Date: Thu, 16 Feb 2012 18:24:54 -0800
Message-ID: <4F3DBA76.8090104@zytor.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>  <1329422549-16407-3-git-send-email-wad@chromium.org>  <4F3D61CB.2000301@zytor.com>  <CABqD9hb3WxKxLZ2GuUrbDM--koW+a3ser5TU8y6+e0sAhOT9dw@mail.gmail.com>  <4F3D7250.6040504@zytor.com>  <CAE6n16kweRehdozft0tKOB1P5LtGFJDCLQP=2EXfm8P0enyH=A@mail.gmail.com>  <4F3D766E.7040205@zytor.com>  <CABqD9haWxRLac1w3m9rSmyDvcg8jxYcxdmAAsgB7pEEBMHr=2g@mail.gmail.com>  <4F3D7DD4.6070103@zytor.com>  <CABqD9hZd41AWZub+wxGWwxJtGWfk+pVWQhn7DM_0q0tS9r_wDA@mail.gmail.com> <1329439809.2337.32.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Will Drewry <wad@chromium.org>,
	Markus Gutschke <markus@chromium.org>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, mingo@redhat.com, oleg@redhat.com,
	peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
	tglx@linutronix.de, luto@mit.edu, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, keescook@chromium.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329439809.2337.32.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/16/2012 04:50 PM, Eric Paris wrote:
> 
> I don't know if anyone cares, but include/linux/audit.h tries to expose
> this type of information so audit userspace can later piece things back
> together.  (we get this info from the syscall entry exit code so we know
> which arch it is).
> 
> Not sure how x32 is hoping to expose its syscall info, but others are
> going to have the same/similar problem.
> 

It would be nice if audit could (eventually?) use the same facility, too.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.
