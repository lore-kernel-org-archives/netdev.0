From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [Bugme-new] [Bug 8668] New: HTB Deadlock
Date: Wed, 27 Jun 2007 13:45:21 +0200
Message-ID: <20070627114521.GA3762@ff.dom.local>
References: <467F8ADA.7060702@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@kernel-bugs.osdl.org>, ranko@spidernet.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:56428 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752170AbXF0LhK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 07:37:10 -0400
Content-Disposition: inline
In-Reply-To: <467F8ADA.7060702@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25-06-2007 11:28, Patrick McHardy wrote:
...
> It is. This patch I had originally planned for 2.6.23 switches HTB
> to the generic estimator, which shouldn't suffer from this.

BTW, maybe I look at this too short, but is this del_timer()
in gen_kill_estimator() enough? I cannot see nothing against
a timer just running and doing mod_timer() again...

Regards,
Jarek P.
