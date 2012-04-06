From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v17 08/15] seccomp: add system call filtering using BPF
Date: Fri, 6 Apr 2012 14:09:29 -0700
Message-ID: <20120406140929.538fd5fd.akpm@linux-foundation.org>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-9-git-send-email-wad@chromium.org>
	<20120406132330.457a05cf.akpm@linux-foundation.org>
	<CAGXu5jJVDLzCOyCo-q6+pF-_3v4Ws8jBzYXwac419uv2QQS0mA@mail.gmail.com>
	<20120406140503.10b75c5b.akpm@linux-foundation.org>
	<4F7F5AB9.5040309@zytor.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>, Will Drewry <wad@chromium.org>,
 linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org,
 linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
 kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
 x86@kernel.org, arnd@arndb.de, davem@davemloft.net, mingo@redhat.com,
 oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
 mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
 serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
 indan@nul.nu, pmoore@redhat.com, corbet@lwn.net, eric.dumazet@gmail.com,
 markus@chromium.org, coreyb@linux.vnet.ibm.com, jmorris@namei.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <kernel-hardening-return-1209-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <4F7F5AB9.5040309@zytor.com>
List-Id: netdev.vger.kernel.org

On Fri, 06 Apr 2012 14:06:01 -0700
"H. Peter Anvin" <hpa@zytor.com> wrote:

> On 04/06/2012 02:05 PM, Andrew Morton wrote:
> >>>
> >>> hm, I'm surprised that we don't have a zero-returning implementation of
> >>> is_compat_task() when CONFIG_COMPAT=n.  Seems silly.  Blames Arnd.
> >>
> >> There is
> > 
> > I can't find it.  The definition in include/linux/compat.h is inside
> > #ifdef CONFIG_COMPAT.
> > 
> 
> I thought Linus globalized it very recently...

Oh, yeah, I misread.

We should be able to remove quite a few open-coded ifdefs now.
