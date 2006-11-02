From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than
	d80211-specific qdisc
Date: Thu, 02 Nov 2006 15:32:34 +0100
Message-ID: <1162477954.10786.11.camel@ux156>
References: <20061026050416.GB14199@havoc.gtf.org>
	 <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net>
	 <20061101112805.246e1b3b@griffin.suse.cz>
	 <20061101142022.GC21668@tuxdriver.com> <4548E7F7.7030100@linux.intel.com>
	 <20061102121657.GA13468@infradead.org> <20061102150550.5c30f704@midnight>
	 <20061102141815.GA1795@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:57514 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750800AbWKBOcI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 09:32:08 -0500
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20061102141815.GA1795@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-02 at 14:18 +0000, Christoph Hellwig wrote:

> This is not about the name that makes sense.  I think using ethX names
> for wireless devices is utterly stupid, but it's what all current upstream
> drivers do, and at least for WE compat we'll have to stick to it.

No, that's not true, zd1201 doesn't [1] :) Has anyoen ever complained
about that? In any case, tools iterate all netdevs and call some
wireless ioctl to check if they are wireless, or
check /proc/net/wireless (which is actually bad, but ...).

Besides, WE never said that names have to have certain names. What makes
you think so?

johannes

[1]
http://kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;h=36b29ff058141a712619e55184566b39ce414efd;hb=aefba081d7b7dfd1c5752f6e6e709d8b5ab80ab7;f=drivers/net/wireless/zd1201.c#l1790

