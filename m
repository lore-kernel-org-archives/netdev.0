From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v12 01/13] sk_run_filter: add support for custom
 load_pointer
Date: Fri, 2 Mar 2012 05:04:41 +0100
Message-ID: <eba2ab81bc32f208b8b94fd959fd7f2f.squirrel@webmail.greenhost.nl>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
    <20120301233712.GS3990@outflux.net>
    <20120302114705.0a9542e138927897f16282ca@canb.auug.org.au>
    <CAGXu5jL0OXR5MOePFe=GT4_X5rdH8RNjQPqYXdbqsqfijUsEqA@mail.gmail.com>
    <20120301171914.7c64f095.akpm@linux-foundation.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "Kees Cook" <keescook@chromium.org>,
 "Stephen Rothwell" <sfr@canb.auug.org.au>,
 "Will Drewry" <wad@chromium.org>,
 linux-kernel@vger.kernel.org,
 linux-arch@vger.kernel.org,
 linux-doc@vger.kernel.org,
 kernel-hardening@lists.openwall.com,
 netdev@vger.kernel.org,
 x86@kernel.org,
 arnd@arndb.de,
 davem@davemloft.net,
 hpa@zytor.com,
 mingo@redhat.com,
 oleg@redhat.com,
 peterz@infradead.org,
 rdunlap@xenotime.net,
 mcgrathr@chromium.org,
 tglx@linutronix.de,
 luto@mit.edu,
 eparis@redhat.com,
 serge.hallyn@canonical.com,
 djm@mindrot.org,
 scarybeasts@gmail.com,
 pmoore@redhat.com,
 corbet@lwn.net,
 eric.dumazet@gmail.com,
 markus@chromium.org,
 coreyb@linux.vnet.ibm.com
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <kernel-hardening-return-1026-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20120301171914.7c64f095.akpm@linux-foundation.org>
List-Id: netdev.vger.kernel.org

On Fri, March 2, 2012 02:19, Andrew Morton wrote:
> That assumes that we're going to merge this stuff into 3.4 - if we
> don't, unwrecker gets rewrecked and grumpy.
>
> I don't know if we're going to merge it into 3.4?  I haven't been
> paying a lot of attention and haven't looked at the patches in a while.

I think it should be merged, but I think 3.5 is probably better.

This because we haven't heard anything from the networking people
about the BPF changes, and I'm also unsure if the current approach
is the best one: It both increases the filter.o size significantly
while slowing down sk_run_filter, while the point was to avoid both.
I'm trying to think of an alternative approach with lower impact.

The ptrace integration may need some more time to settle too, even
just to make sure the latest version does what needs to be done.

Both directly affect the user space ABI, so I think it's best to
not be too hasty with pushing this upstream. Waiting one release
while having a stable final patch gives people the chance to go
and try to use it for their purposes and thus both test the code
more and get experience with the ABI.

Greetings,

Indan
