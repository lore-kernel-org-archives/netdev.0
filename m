From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7]: uninline some net related static inline in .h
 bloaters
Date: Thu, 27 Mar 2008 17:54:56 -0700 (PDT)
Message-ID: <20080327.175456.70727997.davem@davemloft.net>
References: <1206621486-5408-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, acme@redhat.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39257
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753609AbYC1Ay4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 20:54:56 -0400
In-Reply-To: <1206621486-5408-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 27 Mar 2008 14:37:59 +0200

> As suggested by Andrew, I rerun the uninlining of all what's in .h
> (v2.6.25-rc2-mm1 this time) to fix the (un)likely profiling overhead
> which showed up in the allyesconfig results. The config was manually
> tweaked from allyesconfig to not include a number of debug related
> options [1]. Other setup: 32-bit x86, gcc (GCC) 4.1.2 20070626
> (Red Hat 4.1.2-13). I also tweaked the uninlining machinery a bit and
> got even better coverage than last time.

I applied everything and will push to net-2.6.26 after some
build tests.

Thanks!
