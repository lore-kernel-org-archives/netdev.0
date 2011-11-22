From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: 3.2-rc2+: Reported regressions from 3.0 and 3.1
Date: Tue, 22 Nov 2011 11:19:24 +0530
Message-ID: <4ECB37E4.6020204@linux.vnet.ibm.com>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera> <201111212249.31196.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
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
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <201111212249.31196.rjw@sisk.pl>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/22/2011 03:19 AM, Rafael J. Wysocki wrote:
> This message contains a list of some regressions from 3.0 and 3.1
> for which there are no fixes in the mainline known to the tracking te=
am.
> If any of them have been fixed already, please let us know.
>=20
> If you know of any other unresolved regressions from 3.0 and 3.1, ple=
ase let us
> know either and we'll add them to the list.  Also, please let us know=
 if any of
> the entries below are invalid.
>=20
> The entries below are simplified and the statistics are not present d=
ue to the
> continuing Bugzilla outage.
>=20
> Subject    : iwlagn is getting very shaky
> Submitter  : Norbert Preining <preining@logic.at>
> Date       : 2011-10-19 6:01
> Message-ID : 20111019060108.GA11588@gamma.logic.tuwien.ac.at
> References : http://marc.info/?l=3Dlinux-kernel&m=3D131914553920614&w=
=3D2
>=20
> Subject    : Regression: "irqpoll" hasn't been working for me since M=
arch 16 IRQ
> Submitter  : Edward Donovan <edward.donovan@numble.net>
> Date       : 2011-10-19 22:09
> Message-ID : CADdbW+HXdCPfJu2RTF6zz+ujCmiu_dmZwL2iScuF53p=3DAaZ1Uw@ma=
il.gmail.com
> References : http://marc.info/?l=3Dlinux-kernel&m=3D131914554220679&w=
=3D2
>=20
> Subject    : Regression in 3.1 causes Xen to use wrong idle routine
> Submitter  : Stefan Bader <stefan.bader@canonical.com>
> Date       : 2011-10-26 10:24
> Message-ID : 4EA7DFD1.9060608@canonical.com
> References : http://marc.info/?l=3Dlinux-acpi&m=3D131962467924564&w=3D=
2
>=20
> Subject    : 3.1+ iwlwifi lockup
> Submitter  : Dave Jones <davej@redhat.com>
> Date       : 2011-10-31 14:34
> Message-ID : 20111031143408.GA17152@redhat.com
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132007169420160&w=
=3D2
>=20
> Subject    : hugetlb oops on 3.1.0-rc8-devel
> Submitter  : Andy Lutomirski <luto@amacapital.net>
> Date       : 2011-11-01 22:20
> Message-ID : CALCETrW1mpVCz2tO5roaz1r6vnno+srHR-dHA6_pkRi2qiCfdw@mail=
=2Egmail.com
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132018604426692&w=
=3D2
>=20
> Subject    : Simultaneous cat and external keyboard input causing ker=
nel panic
> Submitter  : Timo Jyrinki <timo.jyrinki@gmail.com>
> Date       : 2011-11-03 12:14
> Message-ID : CAJtFfxmovJHspHHKbvBVc4pw+u5mjGmUejCXEzdV+GqE=3DjVSOQ@ma=
il.gmail.com
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132032253903074&w=
=3D2
>=20
> Subject    : Linus GIT - INFO: possible circular locking dependency d=
etected
> Submitter  : Miles Lane <miles.lane@gmail.com>
> Date       : 2011-11-03 15:57
> Message-ID : CAHFgRy8S0xLfhZxTUOEH5A0PL_Fb79-0-gmbQ=3D9h2D-xMqt1hA@ma=
il.gmail.com
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132033587908426&w=
=3D2
>=20
> Subject    : lockdep warning after aa6afca5bcab: "proc: fix races aga=
inst execve() of /proc/PID/fd**"
> Submitter  : Ari Savolainen <ari.m.savolainen@gmail.com>
> Date       : 2011-11-08 3:47
> Message-ID : CAEbykaXYZEFhTgWMm2AfaWQ2SaXYuO_ypTnw+6AVWScOYSCuuw@mail=
=2Egmail.com
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132072413125099&w=
=3D2
>=20
> Subject    : DMA-API check_sync errors with 3.2
> Submitter  : Josh Boyer <jwboyer@redhat.com>
> Date       : 2011-11-08 17:31
> Message-ID : 20111108173153.GE14216@zod.bos.redhat.com
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132077357608797&w=
=3D2
>=20
> Subject    : [3.1-rc8 REGRESSION] sky2 hangs machine on turning off o=
r suspending
> Submitter  : Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> Date       : 2011-11-09 11:46
> Message-ID : CACna6ryTdLcWVYgHu=3D_mRFga1sFivpE_DyZOY-HMmKggkWAJAw@ma=
il.gmail.com
> References : http://marc.info/?l=3Dlinux-netdev&m=3D132083922228088&w=
=3D4
>=20
> Subject    : 3.2-rc1 doesn't boot on dual socket opteron without swap
> Submitter  : Niklas Schnelle <niklas@komani.de>
> Date       : 2011-11-10 20:09
> Message-ID : 1320955769.1718.8.camel@jupiter
> References : http://marc.info/?l=3Dlinux-kernel&m=3D132095583501767&w=
=3D2
>=20
> Subject    : Sparc-32 doesn't work in 3.1.
> Submitter  : Rob Landley <rob@landley.net>
> Date       : 2011-11-12 11:22
> Message-ID : 4EBEAB5A.5020809@landley.net
> References : http://www.spinics.net/lists/kernel/msg1260383.html
>=20
> Subject    : khugepaged blocks suspend2ram (3.2.0-rc1-00252-g8f042aa)
> Submitter  : Sergei Trofimovich <slyich@gmail.com>
> Date       : 2011-11-12 10:48
> Message-ID : 20111112104859.7744b282@sf.home
> References : https://lkml.org/lkml/2011/11/12/11
>=20

Andrea's patch already fixes this issue, which was reported first by
Jiri Slaby. https://lkml.org/lkml/2011/11/11/93
I remember Andrew Morton taking this patch in his -mm tree. But it is
not in mainline yet. So can we consider this closed or not?

Thanks,
Srivatsa S. Bhat

--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
