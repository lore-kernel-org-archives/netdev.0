From: Andreas Mohr <andi@lisas.de>
Subject: Re: [usb regression] Re: [PATCH 2.6.24-rc3] Fix /proc/net breakage
Date: Wed, 2 Jan 2008 07:13:08 +0100
Message-ID: <20080102061308.GB30929@rhlx01.hs-esslingen.de>
References: <20071231052500.GB4187@kroah.com> <Pine.LNX.4.44L0.0712311237150.7182-100000@iolanthe.rowland.org> <20071231192643.GA25341@kroah.com> <20080102060006.GA27693@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Andreas Mohr <andi@lisas.de>, Ingo Molnar <mingo@elte.hu>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Denis V. Lunev" <den@openvz.org>,
	USB list <linux-usb@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:35330 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbYABGNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 01:13:09 -0500
Content-Disposition: inline
In-Reply-To: <20080102060006.GA27693@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Jan 01, 2008 at 10:00:06PM -0800, Greg KH wrote:
> Ok, no, I didn't write that patch, I'm getting very confused here.
> 
> In 2.6.24-rc6 there is no usage of debugfs in the ohci driver.
> 
> In the -mm tree there is a patch, from Tony Jones, that moves some debug
> code out of sysfs and into debugfs where it belongs.  It does it for
> both the ehci and ohci USB host controller drivers, and this is the code
> that is incorrect if CONFIG_DEBUGFS is not enabled.
> 
> So, for the 2.6.24 release, nothing needs to be changed, all is good,
> and there is no regression.
> 
> Right?  Or am I still confused about this whole thing?

Probably, since I also wasn't sure about this getting added to the
post-2.6.23 regressions. I'd expect this problem to be -mm only myself,
but then I didn't actively verify it in code (and I haven't tried -rc6
proper on that machine yet either, build takes ages ;).
OK, since I cannot really offer anything other than positive feelings about
this being non-rc6 breakage, should I try -rc6 proper, too?

> Hm, I wonder if this means I can go back to drinking more holiday
> wine... :)

.....even more confusion? :)

Thanks for your help,

Andreas Mohr
