From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12] sfc changes for 2.6.36
Date: Wed, 02 Jun 2010 06:57:11 -0700 (PDT)
Message-ID: <20100602.065711.191161830.davem@davemloft.net>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
	<20100602.022144.63047920.davem@davemloft.net>
	<1275486746.2870.31.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52111
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758233Ab0FBN5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:57:01 -0400
In-Reply-To: <1275486746.2870.31.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 02 Jun 2010 14:52:26 +0100

> Did you apply patch 12 "sfc: Get port number from CS_PORT_NUM, not PCI
> function number" to net-2.6?

When you mix bug fixes and cleanups, I'm going to apply it all to
net-next-2.6 You didn't even specify an intended destination in your
subject lines, so you leave it entirely open for interpretation and
my choice.

So, if you want a bug fix added to net-2.6, tossing it into a series
which is not wholly appropriate for net-next-2.6 is not that way to
accomplish that.

The way to do it is:

1) Submit the bug fix, explicitly state "[PATCH net-2.6 xxx] "
   in your subject line.

2) Prepare your net-next-2.6 changes on top of that, and do one
   of two things:
   a) Explicitly state in your patch series in the "[PATCH net-next-2.6 0/xxx] "
      posting "this depends upon the bug fixes posted in the series
      XXX posted earlier.
   b) Wait for the bug fix to reach net-next-2.6 when I do a merge,
      then post your series.

Otherwise you make life way to miserable and complicated for me,
the one who has to review and integrate all of your work.

Thanks.
