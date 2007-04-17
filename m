From: Dave Jones <davej@redhat.com>
Subject: Re: [1/2] 2.6.21-rc7: known regressions
Date: Mon, 16 Apr 2007 20:32:12 -0400
Message-ID: <20070417003212.GB22804@redhat.com>
References: <20070416003714.GL3691@stusta.de>
	<36D9DB17C6DE9E40B059440DB8D95F5202505C7E@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, greg@kroah.com,
	linux-ide@vger.kernel.org,
	Michal Jaegermann <michal@ellpspace.math.ualberta.ca>,
	linux-usb-devel@lists.sourceforge.net,
	e1000-devel@lists.sourceforge.net, Adrian Bunk <bunk@stusta.de>,
	linux-acpi@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	jgarzik@pobox.com, lenb@kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Hans-Georg Rist <hg.rist@web.de>, v4l-dvb-maintainer@linuxtv.org,
	perex@suse.cz, Oliver Neukum <oneukum@suse.de>,
	Stephen Clark <Stephen.Clark@seclark.us>, Andi Kleen <ak@suse.de>,
	Markus Rechberger <markus.rechberger@amd.com>,
	netdev@vger.kernel.org, CIJOML <cijoml@volny.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5202505C7E@orsmsx418.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Apr 16, 2007 at 05:14:40PM -0700, Brandeburg, Jesse wrote:
 > Adrian Bunk wrote:
 > > Subject    : laptops with e1000: lockups
 > > References :
 > > https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=229603 
 > > Submitter  : Dave Jones <davej@redhat.com>
 > > Handled-By : Jesse Brandeburg <jesse.brandeburg@intel.com>
 > > Status     : problem is being debugged
 > 
 > this is being actively debugged, here is what we have so far:
 > o v2.6.20: crashes during boot, unless noacpi and nousb bootparams used
 > o v2.6.21-rc6: some userspace issue, crashes just after root mount
 > without init=/bin/bash
 > o v2.6.2X: serial console in docking station spews goo at all speeds
 > with console=ttyS0,bbbbn8 . work continues on this, as we don't know if
 > there are kernel panic messages during the hard lock.
 > o fedora 7 test kernel 2948: boots okay, have been using this as only
 > truly working kernel on this machine.
 > 
 > one reproduction of the problem was had with scp -l 5000 <file> <remote>
 > when linked at 100Mb/Full.  Tried probably 20 other times same test with
 > no repro, ugh.
 > 
 > Otherwise, slogging through continues.  We are actively working on this
 > in case it *is* an e1000 issue.  Right now the repro is so unlikely we
 > could hardly tell if we fixed it.

FWIW, I can reproduce this pretty much ondemand, on 100M through
the ethernet port on a netgear wireless AP.
A number of our Fedora7 testers are also able to easily reproduce this.
To isolate e1000, for tomorrows test build I've reverted e1000 to
the same code that was in 2.6.20.  If that works out without causing
hangs, I'll try and narrow down further which of the dozen csets
is responsible.

	Dave

-- 
http://www.codemonkey.org.uk

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
