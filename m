From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v15 00/13] seccomp_filter: syscall filtering using BPF
Date: Sun, 25 Mar 2012 12:36:25 -0700
Message-ID: <4F6F73B9.2000207@zytor.com>
References: <1331781125-15658-1-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
        netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
        davem@davemloft.net, mingo@redhat.com, oleg@redhat.com,
        peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
        tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
        serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
        indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
        corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
        coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <kernel-hardening-return-1167-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1331781125-15658-1-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

On 03/14/2012 08:11 PM, Will Drewry wrote:
> Please see prior revisions of this patch series for a high
> level blurb.
> 
> This revision makes a number of refinements and tweaks. The biggest
> change is a slight renumbering of the return codes which will break
> existing code using this patch series.
> 
> I believe this patch is in good shape, and I don't see the need for
> any more API changes at this point.  I plan to start using this revision
> more extensively, and I'd certainly appreciate any testing.
> 
> Thanks!
> will
> 

x86 portions:

Reviewed-by: H. Peter Anvin <hpa@zytor.com>

What is the preferred way to push this upstream?  (Presumably for 3.5 at
this point, but we should get it into -next as soon as possible after
the merge window.)

	-hpa
