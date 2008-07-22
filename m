From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [build failure] hp-plus.c: (.text+0xd7c1a): undefined reference
 to `ei_close'
Date: Tue, 22 Jul 2008 11:28:44 +0100
Message-ID: <20080722112844.338d30ff@lxorguk.ukuu.org.uk>
References: <20080721.233512.128618365.anemo@mba.ocn.ne.jp>
	<20080721191519.GA15843@elte.hu>
	<20080721214258.787a67ca@lxorguk.ukuu.org.uk>
	<20080722072334.GA25241@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Atsushi Nemoto <anemo@mba.ocn.ne.jp>, jgarzik@redhat.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:41512 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750971AbYGVKr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 06:47:26 -0400
In-Reply-To: <20080722072334.GA25241@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> find the full tested patch below. It solves the build failures i 
> triggered so far.

Yes - that matches the patch I sent Jeff on the 8th July

Subject: Re: linux-next: Tree for July 8 (ns8390)

From: Alan Cox <alan@redhat.com>

Please try this and if it sorts it fold it into the driver. This is a diff
between my tree and the linux-next tree
---

 drivers/net/hp-plus.c |    2 +-
 drivers/net/hp.c      |    2 +-
 drivers/net/ne.c      |    8 ++++----
 drivers/net/wd.c      |    2 +-
 4 files changed, 7 insertions(+), 7 deletions(-)

