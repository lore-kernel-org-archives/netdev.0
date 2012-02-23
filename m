From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 3.3-rc4+: Reported regressions from 3.2
Date: Thu, 23 Feb 2012 23:51:20 +0100 (CET)
Message-ID: <y44pDJ8xoDC.A.08E.h8rRPB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

We definitely aren't 100% in business yet with the tracking of regressi=
ons,
but since the Bugzilla is operational again, we can collect reports at =
least.

I'd like to use this opportunity to thank Maciej Rutecki and Florian Mi=
ckler
for their hard work on the regression tracking and to clarify some thin=
gs that
seem to have caused some confusion to happen recently.  Namely, we use =
the
kernel Bugzilla (https://bugzilla.kernel.org) for the tracking of regre=
ssions
for the simple reason that our scripts generate the lists that are post=
ed
(like the one below) out of Bugzilla entries created by us (and sometim=
es
by other people).  Those entries are used by us as a storage of informa=
tion,
so we're going to add them even though some kernel developers don't see=
m to
like that.  We don't require developers to actually use those entries f=
or
handling bug reports, we only need people to let us know when they shou=
ld be
closed, because the bug has been fixed in the Linus' tree, or when ther=
e's
a patch available for the bug (in which case we mark it as "resolved", =
but
we don't close it just yet).  There is no reason for you to be openly h=
ostile
to Maciej, who's been creating those entries recently, because he's jus=
t been
doing his job.  However, you may not want us to track kernel regression=
s at
all, in which case please let us know about that and we will find some =
other,
presumably equally interesting things to do. :-)

Yes, we might have been more verbose about what _exactly_ we've been us=
ing the
Bugzilla for and what our workflow is, but at the same time people migh=
t have
been a bit less harsh to someone who's been doing a service to the comm=
unity,
completely voluntarily.

Thanks,
Rafael

---

This message contains a list of some regressions from 3.2,
for which there are no fixes in the mainline known to the tracking team=
=2E
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 3.2, please let us
know either and we'll add them to the list.  Also, please let us know
if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y
to this message with CCs to the people involved in reporting and handli=
ng
the issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2012-02-23       15       13          13


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D42798
Subject		: i915 regression with 3.3-rc3+git
Submitter	: Riccardo Magliocchetti <riccardo.magliocchetti@gmail.com>
Date		: 2012-02-17 20:48 (7 days old)
Message-ID	: <4F3EBD0D.7000906@gmail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132951173002619&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D42776
Subject		: OF-related boot crash in 3.3.0-rc3-00188-g3ec1e88
Submitter	: Meelis Roos <mroos@linux.ee>
Date		: 2012-02-13 7:45 (11 days old)
Message-ID	: <alpine.SOC.1.00.1202130942030.1488@math.ut.ee>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132911916331615&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D42761
Subject		: Possible circular locking dependency (3.3-rc2)
Submitter	: Felipe Balbi <balbi@ti.com>
Date		: 2012-02-08 12:41 (16 days old)
Message-ID	: <20120208124147.GF16334@legolas.emea.dhcp.ti.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132870492311858&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D42746
Subject		: 3.3-rc2 snd_pcm lockdep backtrace
Submitter	: Josh Boyer <jwboyer@redhat.com>
Date		: 2012-02-06 14:56 (18 days old)
Message-ID	: <20120206145621.GA4771@zod.bos.redhat.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132854040916172&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D42735
Subject		: kobject (ffff88003ffbb4b8): tried to init an initialized obj=
ect, something is seriously wrong.
Submitter	: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date		: 2012-02-03 20:59 (21 days old)
Message-ID	: <20120203205953.GA2897@phenom.dumpdata.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132830315526901&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D42734
Subject		: dosemu graphics broken in v3.3-rc1
Submitter	: Hans de Bruin <jmdebruin@xmsnet.nl>
Date		: 2012-02-02 22:25 (22 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/308e5bcbdb10452e8aba31a=
a21432fb67ee46d72
Message-ID	: <4F2B0D4D.3000304@xmsnet.nl>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132825899111982&w=3D=
2
Handled-By	: Jesse Barnes <jbarnes@virtuousgeek.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D42733
Subject		: Regression 3.2 -> 3.3-rc1 10 sec hang at boot and resume, CO=
MRESET failed
Submitter	: Norbert Preining <preining@logic.at>
Date		: 2012-02-02 5:12 (22 days old)
Message-ID	: <20120202051258.GA15550@gamma.logic.tuwien.ac.at>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132815978615112&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D42713
Subject		: Regression in skge that started around acb42a3 (so past v3.3=
-rc1)
Submitter	: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date		: 2012-01-30 15:58 (25 days old)
Message-ID	: <20120130155816.GA1400@phenom.dumpdata.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132793944220262&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D42707
Subject		: Hang deconfiguring network interface (in shutdown) on 3.3-rc=
1
Submitter	: James Bottomley <James.Bottomley@hansenpartnership.com>
Date		: 2012-01-28 19:56 (27 days old)
Message-ID	: <1327780565.2924.24.camel@dabdike.int.hansenpartnership.co=
m>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132778076214873&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D42686
Subject		: iwlagn is getting even worse with 3.3-rc1
Submitter	: Norbert Preining <preining@logic.at>
Date		: 2012-01-24 1:36 (31 days old)
Message-ID	: <20120124013625.GB18436@gamma.logic.tuwien.ac.at>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132736918325378&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D42683
Subject		: WARN... Device 'cpu1' does not have a release() function, it=
 is broken and must be fixed. when doing 'xl vcpu-set <guest_id> 1'
Submitter	: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date		: 2012-01-23 18:06 (32 days old)
Message-ID	: <20120123180601.GA24553@phenom.dumpdata.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132734233916154&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D42678
Subject		: [3.3-rc1] radeon stuck in kernel after lockup
Submitter	: Torsten Kaiser <just.for.lkml@googlemail.com>
Date		: 2012-01-21 19:03 (34 days old)
Message-ID	: <CAPVoSvSXMvRb=3D1itu9DjF+s=3D6zfAChvUxS-x=3Db8EV9kOZinNpA=
@mail.gmail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132717279606670&w=3D=
2
Handled-By	: J=C3=A9r=C3=B4me Glisse <glisse@freedesktop.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D42669
Subject		: 3.3-rc1: compiling problems  nvme , l2cap_sock , mc13892-reg=
ulator , and snd-pcsp don't work
Submitter	: werner <w.landgraf@ru.ru>
Date		: 2012-01-20 18:52 (35 days old)
Message-ID	: <web-682421181@zbackend1.aha.ru>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D132708923719565&w=3D=
2


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 3=
=2E2,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D42644

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!

--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
