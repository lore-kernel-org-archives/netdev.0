From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v15 00/13] seccomp_filter: syscall filtering using BPF
Date: Mon, 26 Mar 2012 11:53:06 -0500
Message-ID: <CABqD9hZe9t9WeMRcuhvevSb9svp5UH9ZHH4TZg753zzcrX-tnQ@mail.gmail.com>
References: <1331781125-15658-1-git-send-email-wad@chromium.org>
	<4F6F73B9.2000207@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, mingo@redhat.com, oleg@redhat.com,
	peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
	tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: "H. Peter Anvin" <hpa@zytor.com>, akpm@linux-foundation.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4F6F73B9.2000207@zytor.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 25, 2012 at 2:36 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 03/14/2012 08:11 PM, Will Drewry wrote:
>> Please see prior revisions of this patch series for a high
>> level blurb.
>>
>> This revision makes a number of refinements and tweaks. The biggest
>> change is a slight renumbering of the return codes which will break
>> existing code using this patch series.
>>
>> I believe this patch is in good shape, and I don't see the need for
>> any more API changes at this point. =A0I plan to start using this re=
vision
>> more extensively, and I'd certainly appreciate any testing.
>>
>> Thanks!
>> will
>>
>
> x86 portions:
>
> Reviewed-by: H. Peter Anvin <hpa@zytor.com>

Thanks!

> What is the preferred way to push this upstream? =A0(Presumably for 3=
=2E5 at
> this point, but we should get it into -next as soon as possible after
> the merge window.)

A repost when rc1 has been cut is what's been suggested to me.

Additionally, two tweaks have been pointed out off list (documentation
cruft and lack if #ifdef for asm/syscall.h), which I have fixed in my
local and github tree but haven't yet reposted here.  I was planning
on just posting v17 when rc1 is cut (unless I've blithely missed it
already) and then trying to pester everyone and anyone who can merge.
:)

Maybe someone more authoritative than me will answer though.

thanks!
will
