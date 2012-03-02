From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v12 01/13] sk_run_filter: add support for custom load_pointer
Date: Thu, 1 Mar 2012 20:39:40 -0600
Message-ID: <CABqD9ha4ACGaVt_VDY9LFJKW1dJ3LrRm=pDyTCQwupLZQ0Ovhg@mail.gmail.com>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
	<20120301233712.GS3990@outflux.net>
	<20120302114705.0a9542e138927897f16282ca@canb.auug.org.au>
	<CAGXu5jL0OXR5MOePFe=GT4_X5rdH8RNjQPqYXdbqsqfijUsEqA@mail.gmail.com>
	<20120301171914.7c64f095.akpm@linux-foundation.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Kees Cook <keescook@chromium.org>, Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	hpa@zytor.com, mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org, coreyb@linux.vnet.ibm.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <kernel-hardening-return-1025-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20120301171914.7c64f095.akpm@linux-foundation.org>
List-Id: netdev.vger.kernel.org

On Thu, Mar 1, 2012 at 7:19 PM, Andrew Morton <akpm@linux-foundation.org> w=
rote:
> On Thu, 1 Mar 2012 16:57:49 -0800 Kees Cook <keescook@chromium.org> wrote=
:
>
>> On Thu, Mar 1, 2012 at 4:47 PM, Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>> > Hi Kees,
>> >
>> > On Thu, 1 Mar 2012 15:37:12 -0800 Kees Cook <keescook@chromium.org> wr=
ote:
>> >>
>> >> Is it time to pull this into -next so more people can feel it? I brou=
ght
>> >> Andy Lutomirski's patches forward (needed to bump the prctl values), =
and
>> >> updated my git tree. If we're ready, here it is in all its request-pu=
ll
>> >> format glory:
>> >>
>> >> The following changes since commit 2422c8368337196594265d52cad7316c94=
04bfcf:
>> >> __ Stephen Rothwell (1):
>> >> __ __ __ __ Add linux-next specific files for 20120301
>> >
>> > OK, not commenting on anything else, but I cannot merge that into
>> > linux-next because it is based on yesterday's linux-next release and
>> > linux-next (effectively) rebases every day ...
>> >
>> > Does this work depend on anything in linux-next? __Or could it be just
>> > based off Linus' tree. __If it depends on other tree(s) merged into
>> > linux-next, then you should base your tree on those tree(s) as long as
>> > they never get rebased ...
>>
>> Unfortunately, yes, it does -- there were both ptrace changes and prctl =
changes.
>>
>> And at least the ptrace changes are, IIRC, in -mm, which has no tree.
>> :P Given that, what's the best thing for me to do for this to be easy
>> for you to pull?
>
> Base the tree on mainline and wreck the -mm patches I guess. =A0I'm good
> at unwrecking patches.
>
> That assumes that we're going to merge this stuff into 3.4 - if we
> don't, unwrecker gets rewrecked and grumpy.
>
> I don't know if we're going to merge it into 3.4? =A0I haven't been
> paying a lot of attention and haven't looked at the patches in a while.
>

I'll roll a v13 which is just a rebase back onto mainline and see if I
can just stage it in kees's tree.

Thanks!
will
