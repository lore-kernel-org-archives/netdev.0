From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific qdisc
Date: Thu, 2 Nov 2006 14:18:15 +0000
Message-ID: <20061102141815.GA1795@infradead.org>
References: <20061026050416.GB14199@havoc.gtf.org> <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net> <20061101112805.246e1b3b@griffin.suse.cz> <20061101142022.GC21668@tuxdriver.com> <4548E7F7.7030100@linux.intel.com> <20061102121657.GA13468@infradead.org> <20061102150550.5c30f704@midnight>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:2984 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1750705AbWKBOTC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 09:19:02 -0500
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20061102150550.5c30f704@midnight>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 02, 2006 at 03:05:50PM +0100, Jiri Benc wrote:
> On Thu, 2 Nov 2006 12:16:57 +0000
> Christoph Hellwig <hch@infradead.org> wrote:
> > The most important merge requirement is to not break userspace.  That means
> > proper support of WE (hopefully via cfg80211), and a single ethX network
> > device.
> 
> Sounds reasonable. Though:
> - I don't think ethX is the appropriate name. It's not an ethernet
>   device and many wireless drivers currently use wlanX name. I think
>   the current wlanX name is a better choice here.

This is not about the name that makes sense.  I think using ethX names
for wireless devices is utterly stupid, but it's what all current upstream
drivers do, and at least for WE compat we'll have to stick to it.

> - Single device is not as easy as it sounds. It would require rather
>   invasive changes in the networking core or ugly hacks in d80211. I'm
>   afraid this is something not achievable in a near future with current
>   number of people working on d80211. But in general, it's doable and
>   desirable, yes.

Again, I'm not sure it's even desirable in the end.  We do however need
a mode in which you can configure a single ethX device with WE and it'll
just work.  It's entirely reasonable to only support a subset of the
functionality that way (no 802.11n, no AP mode, etc)

