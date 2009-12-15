From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 14749] New: Kernel locks up after a few
	minutes of heavy surfing
Date: Tue, 15 Dec 2009 07:54:52 +0000
Message-ID: <20091215075452.GA6488@ff.dom.local>
References: <20091208113645.GA8263@ff.dom.local> <755510.33826.qm@web52905.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, stable@kernel.org,
	Neil Horman <nhorman@tuxdriver.com>
To: Chris Rankin <rankincj@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:24361 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbZLOHzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 02:55:01 -0500
Received: by fg-out-1718.google.com with SMTP id 19so1826965fgg.1
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2009 23:55:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <755510.33826.qm@web52905.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2009 at 05:35:40AM -0800, Chris Rankin wrote:
> --- On Tue, 8/12/09, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > Is it the same .config?
> 
> Similar, but no. I'll attach the .config to the bug tonight.

I can see quite a lot of differences, and some could matter here, e.g.
like these:

-# CONFIG_PREEMPT_RCU is not set
+# CONFIG_TREE_RCU is not set
+CONFIG_PREEMPT_RCU=y
...
-CONFIG_PREEMPT_VOLUNTARY=y
-# CONFIG_PREEMPT is not set
+# CONFIG_PREEMPT_VOLUNTARY is not set
+CONFIG_PREEMPT=y

It's hard to guess, but at least this second patch mentioned by you
(ipv4: additional update of dev_net(dev) to struct *net in
ip_fragment.c) shouldn't matter here. Anyway, now 2.6.32.1 should be
preferred for testing (if possible).

Jarek P.
