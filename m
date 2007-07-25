From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [-mm patch] one e1000 driver should be enough for
	everyone
Date: Wed, 25 Jul 2007 11:05:00 -0400
Message-ID: <46A7669C.5010104@garzik.org>
References: <20070725040304.111550f4.akpm@linux-foundation.org>
	<20070725133650.GB3572@stusta.de> <46A754C7.9080004@garzik.org>
	<20070725144615.GC3572@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Auke Kok <auke-jan.h.kok@intel.com>, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070725144615.GC3572@stusta.de>
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

Adrian Bunk wrote:
> I found the discussion, and Christoph's e1000e sounds like the best name 
> ("new" doesn't say whether it's a new driver for old hardware or a 
> driver for new hardware).

Yeah, I think "e1000new" is a lame name.

e1000e is good, or even e1001e if we wanted even more symmetry :)


> No problem for me, but this obviously implies that global code in the 
> new driver has to be renamed.

Yes.  A global namespace is a global namespace.


> And please ensure that they will always support distinct PCI IDs, or 
> there will be the following common pattern if both drivers support
> a card:

IIRC I think Auke said there is some minor PCI ID overlap that must be 
addressed in the transition.  Disappointing and it raises transition 
issues, but that's the way the split falls out naturally AFAICS.

	Jeff



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
