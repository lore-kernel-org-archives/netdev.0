From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: 2.6.21 known regressions (v2) (for -stable team)
Date: Sat, 28 Apr 2007 18:27:17 +0200
Message-ID: <463375E5.5040108@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: stable@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-acpi@vger.kernel.org,
	Riccardo Ricci <rricci@nuovanetmore.it>,
	"Udo A. Steinberg" <us15@os.inf.tu-dresden.de>,
	Len Brown <len.brown@intel.com>,
	David Brownell <david-b@pacbell.net>,
	Jeff Mahoney <jeffm@suse.com>, reiserfs-dev@namesys.com,
	Jeff Chua <jeff.chua.linux@gmail.com>,
	Francois SIMOND <curio@free.fr>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org,
	=?UTF-8?B?SMOla2FuIExpbmRxdmlzdA==?= <lindqvist@netstar.se>,
	Vincent Frentzel <zcecc22@ucl.ac.uk>,
	=?UTF-8?B?RnJhbsOnb2lzIFZhbGVuZHVj?= <francois.valenduc@skynet.be>,
	Thomas Meyer <thomas.mey@web.de>,
	Giorgio Lando <patroclo7@gmail.com>,
	Dave Jones <davej@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-acpi-owner@vger.kernel.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of known regressions reported after 2.6.21 release.

=46eel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions


Subject    : kernel crash at boot with maxcpus=3D1 on quad core
             kernel BUG at drivers/cpufreq/cpufreq.c:1023
References : http://lkml.org/lkml/2007/4/27/460
Submitter  : Brandeburg, Jesse <jesse.brandeburg@intel.com>
Status     : Unknow

Subject    : Soft lockup on CPU0 when resuming from suspension to ram, =
related to acpi processor module
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D8391
Submitter  : Giorgio Lando <patroclo7@gmail.com>
Status     : Unknow

Subject    : Bad interaction between dynticks and amarok?
References : http://lkml.org/lkml/2007/4/26/307
Submitter  : Thomas Meyer <thomas.mey@web.de>
Status     : Unknow

Subject    : Long pause initializating usb-storage
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D8380
Submitter  : Vincent Frentzel <zcecc22@ucl.ac.uk>
Status     : Unknow

Subject    : Multpiple problem when thermal is loaded with kernel 2.6.2=
1
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D8385
Submitter  : Fran=C3=A7ois Valenduc <francois.valenduc@skynet.be>
Status     : Unknow

Subject    : 2.6.21: sky2 "hw csum failure" problem
References : http://lkml.org/lkml/2007/4/28/105
Submitter  : H=C3=A5kan Lindqvist <lindqvist@netstar.se>
Status     : unknown

Subject    : sky2 regression in 2.6.21: Asus P5B-E Plus ethernet adapte=
r no more supported =20
References : http://lkml.org/lkml/2007/4/26/599
Submitter  : Francois SIMOND <curio@free.fr>=20
Handled-By : Stephen Hemminger <shemminger@linux-foundation.org>
Status     : unknown

Subject    : 2.6.21 - BUG: at arch/i386/kernel/smp.c:177 send_IPI_mask_=
bitmask()
References : http://lkml.org/lkml/2007/4/27/621
Submitter  : Jeff Chua <jeff.chua.linux@gmail.com>
Status     : unknown

Subject    : 2.6.21 don't boot, it stops after ACPI: PCI Interrupt Link=
 [LNKB] (IRQs 3 4 *5 6 7 9 10 11 12 14 15).
References : http://lkml.org/lkml/2007/4/27/400
Submitter  : Riccardo Ricci < rricci@nuovanetmore.it >
Handled-By : Len Brown <lenb@kernel.org>
Status     : unknown

Subject    : ACPI interpreter errors
References : http://lkml.org/lkml/2007/4/27/206
Submitter  : Udo A. Steinberg < us15@os.inf.tu-dresden.de >
Handled-By : Len Brown <lenb@kernel.org>
Status     : unknown

Subject    : reiserfs -- circular locking
References : http://lkml.org/lkml/2007/4/26/648
Submitter  : David Brownell < david-b@pacbell.net >
Handled-By : Jeff Mahoney < jeffm@suse.com >
Patch      : http://lkml.org/lkml/2007/4/27/332
Status     : patch available

Regards,
Michal

--=20
Michal K. K. Piotrowski
Kernel Monkeys
(http://kernel.wikidot.com/start)
-
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
