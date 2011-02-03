From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.38-rc3-git1: Reported regressions 2.6.36 -> 2.6.37
Date: Thu, 3 Feb 2011 07:42:05 -0800
Message-ID: <AANLkTikELiGS+fM5WguZS=Fo-sSXmej1UnKWqCFmnE0k@mail.gmail.com>
References: <e9vOd5LzdBK.A.dyD.h6eSNB@chimera>
	<20110203112316.GA3718@linux-yscl.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>
To: "Carlos R. Mafra" <crmafra2@gmail.com>, Keith Packard <keithp@keithp.com>,
	Dave Airlie <airlied@redhat.com>
Return-path: <dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org>
In-Reply-To: <20110203112316.GA3718@linux-yscl.site>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Sender: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
Errors-To: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 3, 2011 at 3:23 AM, Carlos R. Mafra <crmafra2@gmail.com> wrote:
> On Thu =A03.Feb'11 at =A01:03:41 +0100, Rafael J. Wysocki wrote:
>>
>> If you know of any other unresolved post-2.6.36 regressions, please let =
us know
>> either and we'll add them to the list. =A0Also, please let us know if any
>> of the entries below are invalid.
>
> I'm sorry if I'm overlooking something, but as far as I can see the regre=
ssion
> reported here:
>
> https://lkml.org/lkml/2011/1/24/457
>
> is not in the list (update on that report: reverting that commit on top of
> 2.6.37 fixes the issue).

Ok, added Keith and Dave to the cc, since they are the signers of that comm=
it.

> After some time, I also ended up finding an earlier report in the kernel =
bugzilla
> which I think is the same regression (it was bisected to the same commit):
>
> https://bugzilla.kernel.org/show_bug.cgi?id=3D24982
>
> but I do not see it in the list either, even though it's marked as a
> regression in the bugzilla.
>
> The issue was also present in 2.6.38-rc2 last time I tested.

Just to confirm, can you also check -rc3? I'm pretty sure nothing has
changed, but there were a few drm patches after -rc2, so it's alsways
good to double-check.

Keithp?

                        Linus
