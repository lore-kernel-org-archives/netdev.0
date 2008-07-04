From: Dave Jones <davej@redhat.com>
Subject: Re: Oops/Warning report of the week of July 4th 2008
Date: Fri, 4 Jul 2008 18:23:41 -0400
Message-ID: <20080704222341.GB9792@redhat.com>
References: <486EA0D6.2040504@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, linville@redhat.com
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57961 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753184AbYGDWaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 18:30:39 -0400
Content-Disposition: inline
In-Reply-To: <486EA0D6.2040504@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 04, 2008 at 03:14:46PM -0700, Arjan van de Ven wrote:
 
 > The stats look very similar to last week; Fedora released a 2.6.25.9 based
 > kernel upgrade, which led to a new sighting (at rank 12): the rt25xx wireless
 > driver is calling flush_workqueue() with a NULL parameter in some cases.
 > There has been a lot of thrash about the last report with regard to inclusion of wireless.git
 > into the Fedora kernel rpms. As an observer I can say that it's both a blessing and a bog.
 > It's a blessing in that this allows bugs to show up early before wireless.git hits mainline
 > (as an example: this is the third or fourth fedora rpm upgrade in a row that showed new and exciting
 > oopses/warnings due to rt25xx... as a result of very active development). It's a bog in that
 > it may expose users to not-quite-ready code. So far it seems the Fedora kernel maintainers are happy
 > enough with the overall balance that they continue the practice.

I actually think we need to scale things back a notch wrt pushing
wireless.git bits to users of released distros.  The recent disaster
in wireless caused a shitstorm in bugzilla that we never even saw
in rawhide.  A clear sign that we're pushing things too fast to users.

It's great that we're getting this stuff tested, but at the same time,
it doesn't give a great impression, and makes users reluctant to always
apply the latest updates if the last time around they have to deal with
this kind of fallout.

	Dave

-- 
http://www.codemonkey.org.uk
