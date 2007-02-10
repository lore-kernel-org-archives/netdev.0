From: Pavel Roskin <proski@gnu.org>
Subject: Re: [ANNOUNCE] d80211 based driver for
	Intel	PRO/Wireless 3945ABG
Date: Sat, 10 Feb 2007 12:53:51 -0500
Message-ID: <20070210125351.05uo0o0sgw0w0ckc@webmail.spamcop.net>
References: <45CCE3CA.4050904@linux.intel.com>
	<20070210162254.GC25607@thunk.org>
	<20070210163933.GA17140@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Theodore Tso <tytso@mit.edu>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	ipw3945-devel@lists.sourceforge.net,
	James Ketrenos <jketreno@linux.intel.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <ipw3945-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070210163933.GA17140@tuxdriver.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ipw3945-devel>
List-Post: <mailto:ipw3945-devel@lists.sourceforge.net>
List-Help: <mailto:ipw3945-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw3945-devel-bounces@lists.sourceforge.net
Errors-To: ipw3945-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Quoting "John W. Linville" <linville@tuxdriver.com>:

> > Very cool!  Is it likely that d80211 and iwlwifi will be pushed into
> > mainline in time for 2.6.21?
>
> Hmmm...I think we need to spend a cycle or so in -mm.  2.6.22 seems
> more likely for mainline.

I think we should take this as a goal.  Last time I checked, d80211 wasn't in
-mm.  Perhaps it should go there.  And by the way, the latest changes from
netdev->class_dev to netdev->dev break d80211.  Perhaps we should rebase
wireless-dev immediately after 2.6.21-rc1, fix all compile issues and submit
the patch to -mm.

And iwlwifi is surprisingly good for a just announced driver.  It worked for me
from the first attempt, and that's the first d80211 driver to do so.  In my
opinion, it should go to wireless-dev as soon as possible so it can go to -mm
toghether with other drivers.  A couple of wrinkles in the standalone build
system are irrelevant to the kernel interation.

--
Regards,
Pavel Roskin

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
