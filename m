From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.20-rc4: known unfixed regressions
Date: Mon, 8 Jan 2007 01:22:08 +0100
Message-ID: <20070108002208.GO20714@stusta.de>
References: <Pine.LNX.4.64.0701062216210.3661@woody.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Malte =?iso-8859-1?Q?Schr=F6der?= <MalteSch@gmx.de>,
	Bernhard Schmidt <berni@birkenwald.de>,
	Peter Osterlund <petero2@telia.com>,
	netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org,
	Komuro <komurojun-mbn@nifty.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Cijoml Cijomlovic Cijomlov <cijoml@volny.cz>,
	ttb@tentacle.dhs.org, rml@novell.com,
	Jon Smirl <jonsmirl@gmail.com>,
	Damien Wyart <damien.wyart@free.fr>,
	Aaron Sethman <androsyn@ratbox.org>, alan@lxorguk.ukuu.org.uk,
	linux-ide@vger.kernel.org, Uwe Bugla <uwe.bugla@gmx.de>,
	Tobias Diedrich <ranma+kernel@tdiedrich.de>,
	Andi Kleen <ak@suse.de>, Yinghai Lu <yinghai.lu@amd.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>, mingo@redhat.com,
	discuss@x86-64.org, Florin Iucha <florin@iucha.net>,
	Berthold Cogel <cogel@rrz.uni-koeln.de>,
	Alexey Starikovsk
Return-path: <linux-acpi-owner@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0701062216210.3661@woody.osdl.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This email lists some known regressions in 2.6.20-rc4 compared to 2.6.1=
9.

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way possib=
ly
involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering=
=2E


Subject    : BUG: at mm/truncate.c:60 cancel_dirty_page()
References : http://lkml.org/lkml/2007/1/7/117
Submitter  : Malte Schr=F6der <MalteSch@gmx.de>
Status     : unknown


Subject    : netfilter conntrack Oopses
References : http://lkml.org/lkml/2007/1/4/156
             http://lkml.org/lkml/2007/1/7/188
Submitter  : Bernhard Schmidt <berni@birkenwald.de>
             Peter Osterlund <petero2@telia.com>
Status     : unknown


Subject    : ftp: get or put stops during file-transfer
References : http://lkml.org/lkml/2006/12/16/174
Submitter  : Komuro <komurojun-mbn@nifty.com>
Caused-By  : YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
             commit cfb6eeb4c860592edd123fdea908d23c6ad1c7dc
Handled-By : YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Status     : problem is being debugged


Subject    : BUG: at fs/inotify.c:172 set_dentry_child_flags()
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D7785
Submitter  : Cijoml Cijomlovic Cijomlov <cijoml@volny.cz>
Status     : unknown


Subject    : BUG: scheduling while atomic: hald-addon-stor/...
             cdrom_{open,release,ioctl} in trace
References : http://lkml.org/lkml/2006/12/26/105
             http://lkml.org/lkml/2006/12/29/22
             http://lkml.org/lkml/2006/12/31/133
Submitter  : Jon Smirl <jonsmirl@gmail.com>
             Damien Wyart <damien.wyart@free.fr>
             Aaron Sethman <androsyn@ratbox.org>
Status     : unknown


Subject    : problems with CD burning
References : http://www.spinics.net/lists/linux-ide/msg06545.html
Submitter  : Uwe Bugla <uwe.bugla@gmx.de>
Status     : unknown


Subject    : x86_64 boot failure: "IO-APIC + timer doesn't work"
References : http://lkml.org/lkml/2006/12/16/101
             http://lkml.org/lkml/2007/1/3/9
Submitter  : Tobias Diedrich <ranma+kernel@tdiedrich.de>
Caused-By  : Andi Kleen <ak@suse.de>
             commit b026872601976f666bae77b609dc490d1834bf77
Handled-By : Yinghai Lu <yinghai.lu@amd.com>
             Eric W. Biederman <ebiederm@xmission.com>
Status     : patches are being discussed


Subject    : USB keyboard unresponsive after some time
References : http://lkml.org/lkml/2006/12/25/35
             http://lkml.org/lkml/2006/12/26/106
Submitter  : Florin Iucha <florin@iucha.net>
Status     : unknown


Subject    : Acer Extensa 3002 WLMi: 'shutdown -h now' reboots the syst=
em
References : http://lkml.org/lkml/2006/12/25/40
Submitter  : Berthold Cogel <cogel@rrz.uni-koeln.de>
Handled-By : Alexey Starikovskiy <alexey.y.starikovskiy@linux.intel.com=
>
Status     : problem is being debugged
-
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
