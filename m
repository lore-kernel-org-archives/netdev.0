From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: 2.6.35-rc2-git2: Reported regressions from 2.6.34
Date: Wed, 9 Jun 2010 11:02:34 +0200
Message-ID: <AANLkTiksbL1qHg7Q0A-6TbX0uUrxra4jctUoIGVk5vnE@mail.gmail.com>
References: <Rlf_Qjov7bG.A.a8F.I8rDMB@chimera>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>, dmonakhov@openvz.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <Rlf_Qjov7bG.A.a8F.I8rDMB@chimera>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch from [1] is still missing.

   "cpufreq-call-nr_iowait_cpu-with-disabled-preemption.patch" from
Dmitry Monakhoc

Tested-by: Sedat Dilek <sedat.dilek@gmail.com>
Tested-by Maciej Rutecki <maciej.rutecki@gmail.com>

I have already reported this issue on LKML [2] and cpufreq ML [3].

- Sedat -

[1] http://www.spinics.net/lists/cpufreq/msg01631.html
[2] http://lkml.org/lkml/2010/5/31/77
[3] http://www.spinics.net/lists/cpufreq/msg01637.html

On Wed, Jun 9, 2010 at 12:06 AM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> [NOTES:
> =C2=A0* This by no means is a complete list, but we only put e-mail r=
eports that
> =C2=A0 are at least 1 week old into the Bugzilla.
> =C2=A0* Quite a few of the already reported regressions may be relate=
d to the bug
> =C2=A0 fixed by 386f40c86d6c8d5b717ef20620af1a750d0dacb4 (Revert "tty=
: fix a little
> =C2=A0 bug in scrup, vt.c"), so reporters please retest with this com=
mit applied.]
>
> This message contains a list of some regressions from 2.6.34,
> for which there are no fixes in the mainline known to the tracking te=
am.
> If any of them have been fixed already, please let us know.
>
> If you know of any other unresolved regressions from 2.6.34, please l=
et us
> know either and we'll add them to the list. =C2=A0Also, please let us=
 know
> if any of the entries below are invalid.
>
> Each entry from the list will be sent additionally in an automatic re=
ply
> to this message with CCs to the people involved in reporting and hand=
ling
> the issue.
>
>
> Listed regressions statistics:
>
> =C2=A0Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Total =C2=A0Pending =C2=A0=
Unresolved
> =C2=A0----------------------------------------
> =C2=A02010-06-09 =C2=A0 =C2=A0 =C2=A0 15 =C2=A0 =C2=A0 =C2=A0 13 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A010
>
>
> Unresolved regressions
> ----------------------
>
> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D16163
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : [2.6.35-rc1 Regression] i915: C=
ommit cfecde causes VGA to stay off
> Submitter =C2=A0 =C2=A0 =C2=A0 : David John <davidjon@xenontk.org>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-06-02 12:52 (7 d=
ays old)
> Message-ID =C2=A0 =C2=A0 =C2=A0: <4C065423.3000202@xenontk.org>
> References =C2=A0 =C2=A0 =C2=A0: http://marc.info/?l=3Dlinux-kernel&m=
=3D127548313828613&w=3D2
>
>
> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D16161
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : [2.6.35-rc1 regression] sysfs: =
cannot create duplicate filename ... XVR-600 related?
> Submitter =C2=A0 =C2=A0 =C2=A0 : Mikael Pettersson <mikpe@it.uu.se>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-06-01 19:57 (8 d=
ays old)
> Message-ID =C2=A0 =C2=A0 =C2=A0: <19461.26166.427857.612983@pilspetse=
n.it.uu.se>
> References =C2=A0 =C2=A0 =C2=A0: http://marc.info/?l=3Dlinux-kernel&m=
=3D127542227511925&w=3D2
>
>
> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D16160
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 2.6.35 Radeon KMS power managem=
ent regression?
> Submitter =C2=A0 =C2=A0 =C2=A0 : Nigel Cunningham <ncunningham@crca.o=
rg.au>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-06-01 6:23 (8 da=
ys old)
> Message-ID =C2=A0 =C2=A0 =C2=A0: <4C04A767.8000209@crca.org.au>
> References =C2=A0 =C2=A0 =C2=A0: http://marc.info/?l=3Dlinux-kernel&m=
=3D127537343722290&w=3D2
>
>
> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D16145
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : Unable to boot after "ACPI: Don=
't let acpi_pad needlessly mark TSC unstable"
> Submitter =C2=A0 =C2=A0 =C2=A0 : Tom Gundersen <teg@jklm.no>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-06-07 13:11 (2 d=
ays old)
> Handled-By =C2=A0 =C2=A0 =C2=A0: Venkatesh Pallipadi <venki@google.co=
m>
>
>
> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D16129
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : BUG: using smp_processor_id() i=
n preemptible [00000000] code: jbd2/sda2
> Submitter =C2=A0 =C2=A0 =C2=A0 : Jan Kreuzer <kontrollator@gmx.de>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-06-05 06:15 (4 d=
ays old)
>
>
> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D16122
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 2.6.35-rc1: WARNING at fs/fs-wr=
iteback.c:1142 __mark_inode_dirty+0x103/0x170
> Submitter =C2=A0 =C2=A0 =C2=A0 : Larry Finger <Larry.Finger@lwfinger.=
net>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-06-04 13:18 (5 d=
ays old)
>
>
> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D16120
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : Oops: 0000 [#1] SMP, unable to =
handle kernel NULL pointer dereference at (null)
> Submitter =C2=A0 =C2=A0 =C2=A0 : Alex Zhavnerchik <alex.vizor@gmail.c=
om>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-06-04 09:25 (5 d=
ays old)
> Handled-By =C2=A0 =C2=A0 =C2=A0: Eric Dumazet <eric.dumazet@gmail.com=
>
>
>
> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D16104
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : Radeon KMS does not start after=
 merge of the new PM-Code
> Submitter =C2=A0 =C2=A0 =C2=A0 : Jan Kreuzer <kontrollator@gmx.de>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-06-02 07:47 (7 d=
ays old)
>
>
> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D16090
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : sysfs: cannot create duplicate =
filename
> Submitter =C2=A0 =C2=A0 =C2=A0 : Tobias <devnull@plzk.org>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-06-01 15:59 (8 d=
ays old)
> Handled-By =C2=A0 =C2=A0 =C2=A0: Jesse Barnes <jbarnes@virtuousgeek.o=
rg>
>
>
> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D16037
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : NULL Pointer dereference in __i=
r_input_register/budget_ci_attach
> Submitter =C2=A0 =C2=A0 =C2=A0 : Sean Finney <seanius@debian.org>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-05-23 19:52 (17 =
days old)
>
>
> Regressions with patches
> ------------------------
>
> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D16131
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : kernel BUG at fs/btrfs/extent-t=
ree.c:4363 (btrfs_free_tree_block)
> Submitter =C2=A0 =C2=A0 =C2=A0 : Chow Loong Jin <hyperair@ubuntu.com>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-06-05 18:53 (4 d=
ays old)
> Handled-By =C2=A0 =C2=A0 =C2=A0: Yan Zheng <zheng.yan@oracle.com>
> Patch =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : https://patchwork.kernel.o=
rg/patch/103235/
>
>
> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D16127
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : Boot freeze on HP Compaq nx6325=
 (RS482) with Radeon KMS
> Submitter =C2=A0 =C2=A0 =C2=A0 : Jure Repinc <jlp.bugs@gmail.com>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-06-04 21:14 (5 d=
ays old)
> Handled-By =C2=A0 =C2=A0 =C2=A0: Dave Airlie <airlied@linux.ie>
> Patch =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : https://bugzilla.kernel.or=
g/attachment.cgi?id=3D26677
>
>
> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D16092
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : Caught 64-bit read from uniniti=
alized memory in memtype_rb_augment_cb
> Submitter =C2=A0 =C2=A0 =C2=A0 : Christian Casteyde <casteyde.christi=
an@free.fr>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-06-01 18:08 (8 d=
ays old)
> Handled-By =C2=A0 =C2=A0 =C2=A0: Venki <venki@google.com>
> Patch =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : https://bugzilla.kernel.or=
g/show_bug.cgi?id=3D16092#c2
>
>
> For details, please visit the bug entries and follow the links given =
in
> references.
>
> As you can see, there is a Bugzilla entry for each of the listed regr=
essions.
> There also is a Bugzilla entry used for tracking the regressions from=
 2.6.34,
> unresolved as well as resolved, at:
>
> http://bugzilla.kernel.org/show_bug.cgi?id=3D16055
>
> Please let the tracking team know if there are any Bugzilla entries t=
hat
> should be added to the list in there.
>
> Thanks!
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>
--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
