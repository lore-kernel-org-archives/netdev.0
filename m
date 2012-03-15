From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v15 11/13] ptrace,seccomp: Add PTRACE_SECCOMP support
Date: Thu, 15 Mar 2012 09:40:13 -0500
Message-ID: <CABqD9hZ-i-Aa5+7DTmtQ5JU4EAKQfP=HenqgJeFZ2pftQqoUcg@mail.gmail.com>
References: <1331781125-15658-1-git-send-email-wad@chromium.org>
	<1331781125-15658-12-git-send-email-wad@chromium.org>
	<d2e03d5f063de84d1bae3c3e06296f81.squirrel@webmail.greenhost.nl>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	hpa@zytor.com, mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <kernel-hardening-return-1134-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <d2e03d5f063de84d1bae3c3e06296f81.squirrel@webmail.greenhost.nl>
List-Id: netdev.vger.kernel.org

On Wed, Mar 14, 2012 at 11:49 PM, Indan Zupancic <indan@nul.nu> wrote:
> Hi Will,
>
> On Thu, March 15, 2012 04:12, Will Drewry wrote:
>> @@ -73,6 +74,7 @@
>> =A0#define PTRACE_EVENT_VFORK_DONE =A0 =A0 =A05
>> =A0#define PTRACE_EVENT_EXIT =A0 =A06
>> =A0#define PTRACE_EVENT_STOP =A0 =A07
>> +#define PTRACE_EVENT_SECCOMP 8
>>
>> =A0#include <asm/ptrace.h>
>>
>> @@ -101,8 +103,9 @@
>> =A0#define PT_TRACE_EXEC =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PT_EVENT_FLAG(PT=
RACE_EVENT_EXEC)
>> =A0#define PT_TRACE_VFORK_DONE =A0PT_EVENT_FLAG(PTRACE_EVENT_VFORK_DONE)
>> =A0#define PT_TRACE_EXIT =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PT_EVENT_FLAG(PT=
RACE_EVENT_EXIT)
>> +#define PT_TRACE_SECCOMP =A0 =A0 PT_EVENT_FLAG(PTRACE_EVENT_SECCOMP)
>>
>> -#define PT_TRACE_MASK =A0 =A0 =A0 =A00x000003f4
>> +#define PT_TRACE_MASK =A0 =A0 =A0 =A00x00000ff4
>
> Did you miss this bit?

Kinda.  I'll go ahead and switch it to 0xbf4, but PT_TRACE_MASK
doesn't exist in linux-next so this bit disappears on merge.  However,
it is relevant if people are backporting this code, so I'll push a new
rev of it in a bit if I don't get any other comments (or include it in
the next rev if there are comments).

Thanks!
will
