From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [3/3] 2.6.22-rc1: known regressions v2
Date: Wed, 16 May 2007 22:31:43 +0200
Message-ID: <464B6A2F.9040605@googlemail.com>
References: <464B6743.9000607@googlemail.com> <464B6895.60806@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-usb-devel@lists.sourceforge.net,
	"art@usfltd.com" <art@usfltd.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, video4linux@list.redhat.com,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	Hans Verkuil <hverkuil@xs4all.nl>,
	Robert Fitzsimons <robfitz@273k.net>, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Doug Chapman <doug.chapman@hp.com>, Jeb Cramer <cramerj@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <464B6895.60806@googlemail.com>
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

Hi all,

Here is a list of some known regressions in 2.6.22-rc1.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions



Timers/NOHZ

Subject    : 2.6.21-git4 BUG: soft lockup detected on CPU#1! 
References : http://lkml.org/lkml/2007/5/2/511
Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Handled-By : Thomas Gleixner <tglx@linutronix.de>
Status     : problem is being debugged



USB

Subject    : usb hotplug/udev cannot correctly register usb/scanners
References : http://lkml.org/lkml/2007/5/15/205
Submitter  : art@usfltd.com <art@usfltd.com>
Status     : Unknown



V4L

Subject    : V4L ABI breakage
References : http://lkml.org/lkml/2007/5/14/42
Submitter  : Robert Fitzsimons <robfitz@273k.net>
Caused-By  : Hans Verkuil <hverkuil@xs4all.nl>
             Mauro Carvalho Chehab <mchehab@infradead.org>
             commit 206ebaf32795cf1582b1e2ff2ec6a560c9e986b8
Status     : Unknown



Networking

Subject    : panic with e1000 driver on HP Integrity servers
References : http://bugzilla.kernel.org/show_bug.cgi?id=8455
Submitter  : Doug Chapman <doug.chapman@hp.com>
Caused-By  : Auke Kok <auke-jan.h.kok@intel.com>
             commit e0aac5a289b1dacbc94bd9ae8c449bcdf9ab508c
Status     : problem is being debugged



Regards,
Michal

--
Michal K. K. Piotrowski
Kernel Monkeys
(http://kernel.wikidot.com/start)

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
