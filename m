From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v10 05/11] seccomp: add system call filtering using BPF
Date: Wed, 22 Feb 2012 13:48:17 -0600
Message-ID: <CABqD9ha1mMMe09abu7JA+104GfwYwhH4o1Tp-SxGJTmO849D5Q@mail.gmail.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
	<1329845435-2313-5-git-send-email-wad@chromium.org>
	<4F448C13.1040407@zytor.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org, keescook@chromium.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <kernel-hardening-return-913-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <4F448C13.1040407@zytor.com>
List-Id: netdev.vger.kernel.org

On Wed, Feb 22, 2012 at 12:32 AM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 02/21/2012 09:30 AM, Will Drewry wrote:
>> +
>> +/**
>> + * struct seccomp_data - the format the BPF program executes over.
>> + * @args: up to 6 system call arguments. =A0When the calling convention=
 is
>> + * =A0 =A0 =A0 =A032-bit, the arguments will still be at each args[X] o=
ffset.
>> + * @instruction_pointer: at the time of the system call.
>> + * @arch: indicates system call convention as an AUDIT_ARCH_* value
>> + * =A0 =A0 =A0 =A0as defined in <linux/audit.h>.
>> + * @nr: the system call number
>> + */
>> +struct seccomp_data {
>> + =A0 =A0 __u64 args[6];
>> + =A0 =A0 __u64 instruction_pointer;
>> + =A0 =A0 __u32 arch;
>> + =A0 =A0 int nr;
>> +};
>>
>
> This got flipped around for some reason... that is a problem if we ever
> need to extend this to more than 6 arguments (I thought we had at least
> one architecture which supported 7 arguments already, but I could just
> be delusional.)

Makes sense - I'll put it back in the proper order.

thanks!
