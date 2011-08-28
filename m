From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 3.1-rc3-git6: Reported regressions from 3.0
Date: Sun, 28 Aug 2011 12:49:26 -0700
Message-ID: <CA+55aFxuTmfE3iFL7ko=9ZWDuxenssw69hyEG3bgQxy_QDqgZA__11303.5979833969$1314561047$gmane$org@mail.gmail.com>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera> <20110828193519.GA14132@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39230 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752144Ab1H1TuR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Aug 2011 15:50:17 -0400
In-Reply-To: <20110828193519.GA14132@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 28, 2011 at 12:35 PM, Dave Jones <davej@redhat.com> wrote:
> On Sun, Aug 28, 2011 at 08:22:05PM +0200, Rafael J. Wysocki wrote:
>
> =A0> Bug-Entry =A0 =A0: http://bugzilla.kernel.org/show_bug.cgi?id=3D=
41742
> =A0> Subject =A0 =A0 =A0 =A0 =A0 =A0 =A0: duplicate filename =A0for i=
ntel_backlight with the i915 driver
> =A0> Submitter =A0 =A0: Fran=E7ois Valenduc <francois.valenduc@tvcabl=
enet.be>
> =A0> Date =A0 =A0 =A0 =A0 : 2011-08-25 18:51 (4 days old)
> =A0> First-Bad-Commit: http://git.kernel.org/linus/aaa6fd2a004147bf32=
fce05720938236de3361d9
>
> this should be fixed by b727d20269e8ef1de002bfea8099f5e9db9e9f23

Actually, by a2cc797d2d1a ("i915: do not setup intel_backlight ").

That b727d20269e is just my merge commit that brings in the fix (and
the bogus initialization of 'locked') into mainline.

                   Linus
