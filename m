From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 08/11] nsc-ircc: default to dongle type 9 on IBM
 hardware
Date: Wed, 30 Jul 2008 17:07:20 -0700
Message-ID: <20080730170720.041577ed.akpm@linux-foundation.org>
References: <200807301937.m6UJbfsn012452@imap1.linux-foundation.org>
	<20080730.170057.47288436.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mjg59@srcf.ucam.org,
	ben.collins@canonical.com, samuel@sortiz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51793 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760212AbYGaAH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 20:07:29 -0400
In-Reply-To: <20080730.170057.47288436.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jul 2008 17:00:57 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: akpm@linux-foundation.org
> Date: Wed, 30 Jul 2008 12:37:40 -0700
> 
> > This is necessary to set the dongle type on the nsc driver in order to get
> > it to work correctly.  Thinkpads all appear to use dongle type 9.  This
> > patch defaults nsc devices with an IBM PnP descriptor to use type 9.
> > 
> > Signed-off-by: Matthew Garrett <mjg59@srcf.ucam.org>
> > Signed-off-by: Ben Collins <ben.collins@canonical.com>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> Ugly, but what can we do? :-)

yes, it seems a reasonable compromise short of a full-blown
blacklisting thingy.

> Applied, thanks!

I have a feeling that 2.6.25.x and 2.6.26.x will want this one too.  I
found it hard to judge how important this fix actually is.  But
thinkpads are pretty common!


