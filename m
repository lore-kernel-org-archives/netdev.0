From: Adrian Bunk <bunk@stusta.de>
Subject: [1/6] 2.6.21-rc2: known regressions
Date: Mon, 5 Mar 2007 02:50:31 +0100
Message-ID: <20070305015031.GF3441@stusta.de>
References: <Pine.LNX.4.64.0702272105220.12485@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Ayaz Abdulla <aabdulla@nvidia.com>, maxk@qualcomm.com,
   Jeff Garzik <jeff@garzik.org>, Marcel Holtmann <marcel@holtmann.org>,
   linux-pm@lists.osdl.org,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Sid Boyce <g3vbv@blueyonder.co.uk>, netdev@vger.kernel.org,
   bluez-devel@lists.sourceforge.net, Pavel Machek <pavel@ucw.cz>,
   Matt Mackall <mpm@selenic.com>, Mark Lord <lkml@rtr.ca>,
   Johannes Berg <johannes@sipsolutions.net>,
   Albert Hopkins <kernel@marduk.letterboxes.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
   Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-pm-bounces@lists.osdl.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0702272105220.12485@woody.linux-foundation.org>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.osdl.org>
List-Help: <mailto:linux-pm-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=subscribe>
Sender: linux-pm-bounces@lists.osdl.org
Errors-To: linux-pm-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

This email lists some known regressions in 2.6.21-rc2 compared to 2.6.20
that are not yet fixed in Linus' tree.

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way =

possibly involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering.


Subject    : kwin dies silently
References : http://lkml.org/lkml/2007/2/28/112
Submitter  : Sid Boyce <g3vbv@blueyonder.co.uk>
Status     : unknown


Subject    : resume: slab error in verify_redzone_free(): cache `size-512':
                     memory outside object was overwritten
References : http://lkml.org/lkml/2007/2/24/41
Submitter  : Pavel Machek <pavel@ucw.cz>
Handled-By : Marcel Holtmann <marcel@holtmann.org>
Status     : unknown


Subject    : bluetooth hardlocks
References : http://lkml.org/lkml/2007/3/2/85
Submitter  : Pavel Machek <pavel@ucw.cz>
Status     : unknown


Subject    : Bluetooth RFComm locks up the machine  (device_move() related)
References : http://lkml.org/lkml/2007/3/4/64
Submitter  : Mark Lord <lkml@rtr.ca>
Caused-By  : Marcel Holtmann <marcel@holtmann.org>
             commit c1a3313698895d8ad4760f98642007bf236af2e8
Status     : unknown


Subject    : kref refcounting breakage
References : http://lkml.org/lkml/2007/3/2/67
Submitter  : Andrew Morton <akpm@linux-foundation.org>
Handled-By : Greg KH <greg@kroah.com>
Status     : unknown


Subject    : wireless breakage (ipw2200, iwconfig, NetworkManager)
References : http://lkml.org/lkml/2007/3/4/135
Submitter  : Matt Mackall <mpm@selenic.com>
Caused-By  : Greg Kroah-Hartman <gregkh@suse.de> (?)
             commit 43cb76d91ee85f579a69d42bc8efc08bac560278 (?)
Handled-By : Johannes Berg <johannes@sipsolutions.net>
Status     : unknown


Subject    : forcedeth: skb_over_panic
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D8058
Submitter  : Albert Hopkins <kernel@marduk.letterboxes.org>
Status     : unknown
