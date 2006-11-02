From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than
	d80211-specific qdisc
Date: Thu, 02 Nov 2006 15:22:37 +0100
Message-ID: <1162477358.10786.4.camel@ux156>
References: <20061026050416.GB14199@havoc.gtf.org>
	 <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net>
	 <20061101112805.246e1b3b@griffin.suse.cz>
	 <20061101142022.GC21668@tuxdriver.com> <4548E7F7.7030100@linux.intel.com>
	 <20061102121657.GA13468@infradead.org>  <20061102150550.5c30f704@midnight>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:7623 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750708AbWKBOWD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 09:22:03 -0500
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20061102150550.5c30f704@midnight>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-02 at 15:05 +0100, Jiri Benc wrote:
> - Single device is not as easy as it sounds. It would require rather
>   invasive changes in the networking core or ugly hacks in d80211. I'm
>   afraid this is something not achievable in a near future with current
>   number of people working on d80211. But in general, it's doable and
>   desirable, yes.

Actually, just as a note to all the others (talked to Jiri about it
already), I think it's easier than thought since the code is so
convoluted. The only purpose of the wmaster device appears to be to have
an outgoing frame queue through the qdisc. Since we require the 802.11
qdisc to be installed at the root for all netdevices anyway, we could
just as well hand the frame to it right away.

I'll look into that later today.

johannes
