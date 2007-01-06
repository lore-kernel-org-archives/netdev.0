From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.20-rc3: known unfixed regressions (v4)
Date: Sat, 6 Jan 2007 22:04:17 +0100
Message-ID: <20070106210417.GA20714@stusta.de>
References: <Pine.LNX.4.64.0612311710430.4473@woody.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Tobias Diedrich <ranma+kernel@tdiedrich.de>,
	Andi Kleen <ak@suse.de>, Yinghai Lu <yinghai.lu@amd.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>, mingo@redhat.com,
	discuss@x86-64.org, Jon Smirl <jonsmirl@gmail.com>,
	Damien Wyart <damien.wyart@free.fr>,
	Aaron Sethman <androsyn@ratbox.org>, alan@lxorguk.ukuu.org.uk,
	linux-ide@vger.kernel.org, Uwe Bugla <uwe.bugla@gmx.de>,
	Florin Iucha <florin@iucha.net>, greg@kroah.com,
	linux-usb-devel@lists.sourceforge.net, dmitry.torokhov@gmail.com,
	linux-input@atrey.karlin.mff.cuni.cz,
	Berthold Cogel <cogel@rrz.uni-koeln.de>,
	Alexey Starikovskiy <alexey.y.starikovskiy@linux.intel.com>,
	len.brown@intel.com, linux-acpi@vger.kernel.org,
	Komuro <komurojun-mbn@nifty.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, Hugh Dickins <hugh@veritas.com>,
	Marcus
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:4264 "HELO
	mailout.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932210AbXAFVEP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Jan 2007 16:04:15 -0500
To: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0612311710430.4473@woody.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This email lists some known regressions in 2.6.20-rc3 compared to 2.6.19
that are not yet fixed in Linus' tree.

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way possibly
involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering.


Subject    : x86_64 boot failure: "IO-APIC + timer doesn't work"
References : http://lkml.org/lkml/2006/12/16/101
             http://lkml.org/lkml/2007/1/3/9
Submitter  : Tobias Diedrich <ranma+kernel@tdiedrich.de>
Caused-By  : Andi Kleen <ak@suse.de>
             commit b026872601976f666bae77b609dc490d1834bf77
Handled-By : Yinghai Lu <yinghai.lu@amd.com>
             Eric W. Biederman <ebiederm@xmission.com>
Status     : patches are being discussed


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


Subject    : USB keyboard unresponsive after some time
References : http://lkml.org/lkml/2006/12/25/35
             http://lkml.org/lkml/2006/12/26/106
Submitter  : Florin Iucha <florin@iucha.net>
Status     : unknown


Subject    : Acer Extensa 3002 WLMi: 'shutdown -h now' reboots the system
References : http://lkml.org/lkml/2006/12/25/40
Submitter  : Berthold Cogel <cogel@rrz.uni-koeln.de>
Handled-By : Alexey Starikovskiy <alexey.y.starikovskiy@linux.intel.com>
Status     : problem is being debugged


Subject    : ftp: get or put stops during file-transfer
References : http://lkml.org/lkml/2006/12/16/174
Submitter  : Komuro <komurojun-mbn@nifty.com>
Caused-By  : YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
             commit cfb6eeb4c860592edd123fdea908d23c6ad1c7dc
Handled-By : YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Status     : problem is being debugged


Subject    : PIE randomization causes random failures of kernel compiles
References : http://lkml.org/lkml/2007/1/6/124
Submitter  : Hugh Dickins <hugh@veritas.com>
Caused-By  : Marcus Meissner <meissner@suse.de>
             commit 59287c0913cc9a6c75712a775f6c1c1ef418ef3b
Handled-By : Hugh Dickins <hugh@veritas.com>
Patch      : http://lkml.org/lkml/2007/1/6/124
Status     : patch was suggested

