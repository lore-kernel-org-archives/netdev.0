From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific
 qdisc
Date: Thu, 2 Nov 2006 15:05:50 +0100
Message-ID: <20061102150550.5c30f704@midnight>
References: <20061026050416.GB14199@havoc.gtf.org>
	<C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net>
	<20061101112805.246e1b3b@griffin.suse.cz>
	<20061101142022.GC21668@tuxdriver.com>
	<4548E7F7.7030100@linux.intel.com>
	<20061102121657.GA13468@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:49555 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1752444AbWKBODN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 09:03:13 -0500
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20061102121657.GA13468@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2 Nov 2006 12:16:57 +0000
Christoph Hellwig <hch@infradead.org> wrote:
> The most important merge requirement is to not break userspace.  That means
> proper support of WE (hopefully via cfg80211), and a single ethX network
> device.

Sounds reasonable. Though:
- I don't think ethX is the appropriate name. It's not an ethernet
  device and many wireless drivers currently use wlanX name. I think
  the current wlanX name is a better choice here.
- Single device is not as easy as it sounds. It would require rather
  invasive changes in the networking core or ugly hacks in d80211. I'm
  afraid this is something not achievable in a near future with current
  number of people working on d80211. But in general, it's doable and
  desirable, yes.

> The second most important is proper smp support, or good code
> quality in general.  We can't afford to merge buggy code.

I definitely agree here.

> Third most
> important is to make sure it's a full replacment for the current ieee80211
> code - for the softmac cards that's mostly trivial, but the half-hard mac
> old intel cards are hard.  That's where intel comes into play because you
> support that hardware _and_ are pushing for d80211.  That makes your team
> pretty much volunteer to fix that up in my eyes.

Let's see...

 Jiri

-- 
Jiri Benc
SUSE Labs
