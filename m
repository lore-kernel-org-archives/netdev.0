From: Alex Deucher <alexdeucher@gmail.com>
Subject: Re: 2.6.37-rc2-git4: Reported regressions 2.6.35 -> 2.6.36
Date: Fri, 19 Nov 2010 18:17:54 -0500
Message-ID: <AANLkTi==0+pNswCwfgo5v5tKA+Qkq7UfRdH4ftEqx7rf@mail.gmail.com>
References: <tTUH_XeInOH.A.dMF.c3b5MB@chimera>
	<4CE5C919.7090504@teksavvy.com>
	<AANLkTi=8G7pNA7QTxaXDWKrWrCERPfmKU+nLJWCA=JUH@mail.gmail.com>
	<4CE7006E.4040102@teksavvy.com>
	<AANLkTim9aXi1_EJyh2f-+X4HnNWJ3uk2z=P6m1hQso5a@mail.gmail.com>
	<4CE70543.2000206@teksavvy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>
To: Mark Lord <kernel@teksavvy.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <4CE70543.2000206@teksavvy.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 19, 2010 at 6:16 PM, Mark Lord <kernel@teksavvy.com> wrote:
> On 10-11-19 05:58 PM, Alex Deucher wrote:
>>
>> On Fri, Nov 19, 2010 at 5:55 PM, Mark Lord<kernel@teksavvy.com> =A0w=
rote:
>>
>>> It now comes back at resume time.
>>
>> So that patch helped?
>
> I think so. =A0It didn't used to resume from suspend with 2.6.36, and=
 now it
> does.
>
>>> But suffers long delays (also sometimes with 2.6.35) doing this:
>>>
>>> [drm:atom_op_jump] *ERROR* atombios stuck in loop for more than 5se=
cs
>>> aborting
>>> [drm:atom_execute_table_locked] *ERROR* atombios stuck executing E5=
76
>>> (len
>>> 105, WS 12, PS 8) @ 0xE5C4
>>> [drm:atom_op_jump] *ERROR* atombios stuck in loop for more than 5se=
cs
>>> aborting
>>> [drm:atom_execute_table_locked] *ERROR* atombios stuck executing EC=
D2
>>> (len
>>> 86, WS 4, PS 0) @ 0xED05
>>> [drm:atom_op_jump] *ERROR* atombios stuck in loop for more than 5se=
cs
>>> aborting
>>> [drm:atom_execute_table_locked] *ERROR* atombios stuck executing E5=
76
>>> (len
>>> 105, WS 12, PS 8) @ 0xE5C4
>>> PM: resume of devices complete after 15718.253 msecs
>>>
>>
>> It's be nice if you could bisect to track down when those started.
>
> It'd be even nicer if they hadn't started. =A0:)
>
> What kernel release first had that atom/ops table in it? =A0I'll try =
that.
>

2.6.31 or 32 was when radeon kms got merged IIRC.

Alex
--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
