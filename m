From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Fw: [Bugme-new] [Bug 8057] New: slab corruption running ip6sic
Date: Mon, 12 Mar 2007 11:29:45 +0100
Message-ID: <20070312102945.GC1664@ff.dom.local>
References: <20070222134918.e2f1af6d.akpm@linux-foundation.org> <20070312102403.GB1664@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@bugzilla.kernel.org>, snakebyte@gmx.de
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:42539 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965485AbXCLKZe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2007 06:25:34 -0400
Content-Disposition: inline
In-Reply-To: <20070312102403.GB1664@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 12, 2007 at 11:24:03AM +0100, Jarek Poplawski wrote:
...
> I think your diagnose is correct (all "return -1" should be
> changed to "return 0" in xfrm6_input.c).

Sorry! Of course should be:

I think your diagnose is correct (all "return -1" should be
changed to "return 0" in xfrm6_rcv_spi()).

Jarek P.
