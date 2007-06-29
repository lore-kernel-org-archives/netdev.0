From: Jeff Garzik <jeff@garzik.org>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 16:59:43 -0400
Message-ID: <468572BF.1050904@garzik.org>
References: <1183138159.17243.16.camel@blaa>
	<20070629175006.GB3917@falooley.org> <468562A6.8060901@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	Mark McLoughlin <markmc@redhat.com>,
	Jason Lunz <lunz@reflexsecurity.com>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <468562A6.8060901@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> I disagree, we should not break the current e1000 driver in the kernel 
> while there is a new driver coming up that introduces ich9 support 
> without breaking (the old e1000) support for all other devices. This is 
> why we want to drop a new version of the e1000 driver upstream instead, 
> and put all newer devices in that driver.

If it's clean -and- new hardware is quite different from older hardware, 
a new driver makes sense, and causes far less disruption to both new and 
old hardware.


> For distro's not following kernel.org releases we have the perfect 
> solution: A fully tested 7.5.5 driver on sourceforge that was 
> extensively tested against RHEL5 for instance, but also a lot of other 
> older kernels.

I respectfully object to the advertising, here.

Based on past history, "posted on sf.net and tested by Intel" does not 
equate to "extensively tested."  Field experience proves time and again 
that PickYourVendor test labs always miss the raft of problems that show 
up once code is upstream and in production use.  If the code has never 
seen Internet-wide testing in an upstream kernel, it's -not- widely nor 
extensively tested.

	Jeff




-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
