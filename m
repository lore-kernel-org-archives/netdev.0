From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific
 qdisc
Date: Thu, 2 Nov 2006 16:42:13 +0100
Message-ID: <20061102164213.19bc6176@griffin.suse.cz>
References: <20061026050416.GB14199@havoc.gtf.org>
	<C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net>
	<20061101112805.246e1b3b@griffin.suse.cz>
	<20061101142022.GC21668@tuxdriver.com>
	<4548E7F7.7030100@linux.intel.com>
	<20061102121657.GA13468@infradead.org>
	<20061102150550.5c30f704@midnight>
	<20061102141815.GA1795@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:56704 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751392AbWKBPmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 10:42:16 -0500
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20061102141815.GA1795@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2 Nov 2006 14:18:15 +0000, Christoph Hellwig wrote:
> This is not about the name that makes sense.  I think using ethX names
> for wireless devices is utterly stupid, but it's what all current upstream
> drivers do, and at least for WE compat we'll have to stick to it.

That's not true. Look at hostap or zd1201, for example. Also, ethX name
is not needed for WE compatibility. And because of various names used
by various drivers (madwifi uses ath0, for example) config scripts
don't depend on ethX name today anyway.

 Jiri

-- 
Jiri Benc
SUSE Labs
