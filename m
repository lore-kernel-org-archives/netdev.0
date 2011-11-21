From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 3.2-rc2+: Reported regressions from 3.0 and 3.1
Date: Mon, 21 Nov 2011 14:11:54 -0800
Message-ID: <CA+55aFwAELQieN=qR7Gz_MT5rHPp90H10uTMS+DOJjefk7q3ng@mail.gmail.com>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera> <201111212249.31196.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45199 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753692Ab1KUWMR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 17:12:17 -0500
In-Reply-To: <201111212249.31196.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 21, 2011 at 1:49 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>
> Subject =A0 =A0: [3.1 REGRESSION] Commit 5cec93c216db77c45f7ce970d462=
83bcb1933884 breaks the Chromium seccomp sandbox
> Submitter =A0: Nix <nix@esperi.org.uk>
> Date =A0 =A0 =A0 : 2011-11-14 0:40
> Message-ID : 8762inleno.fsf@spindle.srvr.nix
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132123396226377&w=
=3D2

So this should be fixed by commit 2b666859ec32 ("x86: Default to
vsyscall=3Dnative for now"), since we disabled the vsyscall emulation
because it broken UML too.

Of course, the chromium seccomp thing might re-surface with the
patches that enable the emulation (with better emulation), which Andy
is still working on, and that I was planning on merging for 3.3.

Andy, it migth be worth contacting Nix and having him test whether
your fixed emulation works for chromium too.

                      Linus
