From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [1/2] 2.6.21-rc7: known regressions
Date: Mon, 16 Apr 2007 17:14:40 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5202505C7E@orsmsx418.amr.corp.intel.com>
References: <20070416003714.GL3691@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Hans-Georg Rist" <hg.rist@web.de>, <perex@suse.cz>,
	<alsa-devel@alsa-project.org>,
	"Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>,
	"Stephen Clark" <Stephen.Clark@seclark.us>, <jgarzik@pobox.com>,
	<linux-ide@vger.kernel.org>,
	"Michal Jaegermann" <michal@ellpspace.math.ualberta.ca>,
	<lenb@kernel.org>, <linux-acpi@vger.kernel.org>,
	<netdev@vger.kernel.org>, "Dave Jones" <davej@redhat.com>,
	<e1000-devel@lists.sourceforge.net>, "Ingo Molnar" <mingo@elte.hu>,
	"Ayaz Abdulla" <aabdulla@nvidia.com>,
	"David Miller" <davem@davemloft.net>, "Andi Kleen" <ak@suse.de>,
	"Oliver Neukum" <oneukum@suse.de>, <greg@kroah.com>,
	<linux-usb-devel@lists.sourceforge.net>,
	"CIJOML" <cijoml@volny.cz>,
	"Markus Rechberger" <markus.rechberger@amd.com>,
	<v4l-dvb-maintainer@linuxtv.org>
To: "Adrian Bunk" <bunk@stusta.de>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Andrew Morton" <akpm@linux-foundation.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20070416003714.GL3691@stusta.de>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> Subject    : laptops with e1000: lockups
> References :
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=229603 
> Submitter  : Dave Jones <davej@redhat.com>
> Handled-By : Jesse Brandeburg <jesse.brandeburg@intel.com>
> Status     : problem is being debugged

this is being actively debugged, here is what we have so far:
o v2.6.20: crashes during boot, unless noacpi and nousb bootparams used
o v2.6.21-rc6: some userspace issue, crashes just after root mount
without init=/bin/bash
o v2.6.2X: serial console in docking station spews goo at all speeds
with console=ttyS0,bbbbn8 . work continues on this, as we don't know if
there are kernel panic messages during the hard lock.
o fedora 7 test kernel 2948: boots okay, have been using this as only
truly working kernel on this machine.

one reproduction of the problem was had with scp -l 5000 <file> <remote>
when linked at 100Mb/Full.  Tried probably 20 other times same test with
no repro, ugh.

Otherwise, slogging through continues.  We are actively working on this
in case it *is* an e1000 issue.  Right now the repro is so unlikely we
could hardly tell if we fixed it.

Jesse

PS .config available on request
