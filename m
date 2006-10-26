From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific qdisc
Date: Thu, 26 Oct 2006 01:04:16 -0400
Message-ID: <20061026050416.GB14199@havoc.gtf.org>
References: <20061026023838.GA6032@havoc.gtf.org> <C86180A8C204554D8A3323D8F6B0A29F018B54F4@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:44956 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S1422916AbWJZFES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 01:04:18 -0400
To: Simon Barber <simon@devicescape.com>
Content-Disposition: inline
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F018B54F4@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 25, 2006 at 08:37:04PM -0700, Simon Barber wrote:
> Doing this will slow down the qdisc - it does already run an external
> classifier first if you install one. On typical laptops performance is
> not a problem, but one common usage does have problems. The performance
> of a wireless home gateway based on a simple linux kernel configuration
> (NAT, iptables, bridging) is significantly slower than a VxWorks based
> one. With the arrival of 802.11n improving the performance of the stack
> is very important. The VxWorks solution may be less flexible in terms of
> what it can do, but it will allow the full 802.11n bandwidth to be
> achieved on slower embedded CPUs than Linux does. How to improve the
> linux kernel networking to improve it's efficiency here is a hard
> problem.

First do it right, then tune performance.  If you aren't doing it right,
then who cares about VxWorks.

We also need 802.11 to register as a real protocol, rather than faking
ethernet.  David Miller did an example stub:
http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/davem-p80211.tar.bz2

	Jeff



