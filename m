From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v8 3/8] seccomp: add system call filtering using BPF
Date: Thu, 16 Feb 2012 22:40:51 -0600
Message-ID: <CABqD9haCev6CKyAU+JmZTxQfRpThiz4HOT7uJkvrjAEUO6=iJw@mail.gmail.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
	<1329422549-16407-3-git-send-email-wad@chromium.org>
	<4F3D61CB.2000301@zytor.com>
	<CABqD9hb3WxKxLZ2GuUrbDM--koW+a3ser5TU8y6+e0sAhOT9dw@mail.gmail.com>
	<4F3D7250.6040504@zytor.com>
	<CAE6n16kweRehdozft0tKOB1P5LtGFJDCLQP=2EXfm8P0enyH=A@mail.gmail.com>
	<4F3D766E.7040205@zytor.com>
	<CABqD9haWxRLac1w3m9rSmyDvcg8jxYcxdmAAsgB7pEEBMHr=2g@mail.gmail.com>
	<4F3D7DD4.6070103@zytor.com>
	<CABqD9hZd41AWZub+wxGWwxJtGWfk+pVWQhn7DM_0q0tS9r_wDA@mail.gmail.com>
	<1329439809.2337.32.camel@localhost>
	<CABqD9hY06gaA7T8f0Te9PFpip6ix7CcbRShWcXutxbivEZJ2og@mail.gmail.com>
	<4F3DD39C.9090905@zytor.com>
	<CABqD9haiko3xLUKFp_MZcd8G7Hsyif75ABk1HOVKNJ7=NZRRsA@mail.gmail.com>
	<4F3DD84B.30808@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Paris <eparis@redhat.com>,
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
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:33516 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751036Ab2BQEkx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Feb 2012 23:40:53 -0500
In-Reply-To: <4F3DD84B.30808@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 16, 2012 at 10:32 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 02/16/2012 08:26 PM, Will Drewry wrote:
>>>
>>> For x32 you have the option of introducing a new value or relying o=
n bit
>>> 30 in eax (and AUDIT_ARCH_X86_64). =A0The latter is more natural, p=
robably.
>>
>> Will that bit be visible as the syscall number or will it be strippe=
d
>> out before passing the number around? =A0If it's visible, then it
>> doesn't seem like there'd need to be a new AUDIT_ARCH, but I suspect
>> someone like Eric will have an actually useful opinion.
>>
>
> Bit 30 is visible in orig_eax; whether you export it as part of "the
> syscall number" is presumably TBD, but I think it's more natural to d=
o so.

That's what I meant - thanks!
