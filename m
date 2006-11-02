From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific qdisc
Date: Thu, 2 Nov 2006 09:06:54 -0500
Message-ID: <20061102140648.GA32377@tuxdriver.com>
References: <20061026050416.GB14199@havoc.gtf.org> <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net> <20061101112805.246e1b3b@griffin.suse.cz> <20061101142022.GC21668@tuxdriver.com> <4548E7F7.7030100@linux.intel.com> <20061102121657.GA13468@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Ketrenos <jketreno@linux.intel.com>,
	Jiri Benc <jbenc@suse.cz>,
	Simon Barber <simon@devicescape.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:49418 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1752897AbWKBOKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 09:10:17 -0500
To: Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20061102121657.GA13468@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 02, 2006 at 12:16:57PM +0000, Christoph Hellwig wrote:

> The most important merge requirement is to not break userspace.  That means
> proper support of WE (hopefully via cfg80211), and a single ethX network
> device.  The second most important is proper smp support, or good code
> quality in general.  We can't afford to merge buggy code.  Third most
> important is to make sure it's a full replacment for the current ieee80211
> code - for the softmac cards that's mostly trivial, but the half-hard mac
> old intel cards are hard.  That's where intel comes into play because you
> support that hardware _and_ are pushing for d80211.  That makes your team
> pretty much volunteer to fix that up in my eyes.

+1

This aligns very well with my position.

John
-- 
John W. Linville
linville@tuxdriver.com
