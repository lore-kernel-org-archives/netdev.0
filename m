From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CUBIC v2.3 with new improved slow start
Date: Sun, 02 Nov 2008 00:27:36 -0700 (PDT)
Message-ID: <20081102.002736.193701976.davem@davemloft.net>
References: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rhee@eos.ncsu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55537
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752509AbYKBH2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 02:28:03 -0500
In-Reply-To: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Injong Rhee" <rhee@eos.ncsu.edu>
Date: Wed, 29 Oct 2008 17:28:26 -0400

> I am releasing a new patch for CUBIC. This patch implements a new
> slow start mechanism called HyStart. There were some discussions in
> the mailing list on the poor performance of TCP slow start; our
> patch addresses those performance issues arising from slow start.

I'm applying this patch to net-next-2.6 for three reasons:

1) it is easily the cleanest and most well done CUBIC patch submission,
   and they should be rewarded for the quality of this work

2) the only way to get exposure is to merge this now and look out for
   problems, and yes that means keeping it the default

3) if there is a problem it's a one line change to revert to previous
   CUBIC behvaior, by setting hystart to 0, and that's always a safe
   alternative because that is pretty much what is deployed all over
   the world right now

Thanks!
