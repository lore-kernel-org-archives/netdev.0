From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v12 06/13] seccomp: add system call filtering using BPF
Date: Fri, 2 Mar 2012 09:12:58 +0100
Message-ID: <5e22306601c1718407f477e64d2e75b9.squirrel@webmail.greenhost.nl>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
    <1330559620-23543-6-git-send-email-wad@chromium.org>
    <a6fdbe9d1daf6864589c9affc7048965.squirrel@webmail.greenhost.nl>
    <4F50603B.7040505@zytor.com>
    <bc1b4ec8fbad5a5931a928f108a6095f.squirrel@webmail.greenhost.nl>
    <4F506EE2.1050705@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "Will Drewry" <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4F506EE2.1050705@zytor.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, March 2, 2012 07:55, H. Peter Anvin wrote:
> On 03/01/2012 10:43 PM, Indan Zupancic wrote:
> Ok, fail on my part - I misread the above to refer to @arch, not
> @instruction_pointer.

Ah, that explains a lot.

>>> -- Pin is a great example.
>> Is that http://www.pintool.org/?
>>
>> Can you explain how knowing the IP is useful for Pin?
>>
>> All I am asking for is just one use case for providing the IP. Is that
>> asking for too much?
>
> However, it still applies.  For something like Pin, Pin may want to trap
> on all or a subset from the instrumented program, while the
> instrumentation code -- which lives in the same address space -- needs
> to execute those same instructions.
>
> Yes, it's useless for *security* (unless perhaps if you keep very strict
> tabs on the flow of control by using debug registers, dynamic
> translation or whatnot), but it can be highly useful for
> *instrumentation*, where you want to analyze the behavior of a
> non-malicious program.

That is a good use case indeed, I'm convinced.

Thanks,

Indan


