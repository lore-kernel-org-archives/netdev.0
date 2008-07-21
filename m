From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] sky2: Adapt sky2 to use reworked PCI PM
Date: Sun, 20 Jul 2008 19:07:42 -0700
Message-ID: <20080720190742.84258d7e.akpm@linux-foundation.org>
References: <200807191436.40726.rjw@sisk.pl>
	<200807191442.52759.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, Jeff Garzik <jeff@garzik.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57792 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758404AbYGUCIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 22:08:18 -0400
In-Reply-To: <200807191442.52759.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 19 Jul 2008 14:42:51 +0200 "Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> Adapt the sky2 driver to use the reworked PCI PM.

I fixed the rejects in "[PATCH 3/4] tg3: Adapt tg3 to use reworked PCI
PM code" but this patch has too many for me to want to fix them.

As usual, please at least take a look at what's in linux-next before
going and bypassing all that queued work.

Patches 3 and 4 (which are Jeff things) depend upon patch 2, which is a
Jesse thing.  So I will attempt to not send patches 3 and 4 (assuming 4
gets fixed) to Jeff until Jesse has sent #2 into mainline.  This should
be interesting.
