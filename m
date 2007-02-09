From: David Miller <davem@davemloft.net>
Subject: Re: A potential bug in tcp_vegas.c
Date: Thu, 08 Feb 2007 16:08:45 -0800 (PST)
Message-ID: <20070208.160845.115912909.davem@davemloft.net>
References: <7335583a0702011303y5f3565d1r70a79eae94db6348@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davidwei79@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44919
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1422759AbXBIAIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 19:08:46 -0500
In-Reply-To: <7335583a0702011303y5f3565d1r70a79eae94db6348@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: "Xiaoliang (David) Wei" <davidwei79@gmail.com>
Date: Thu, 1 Feb 2007 13:03:49 -0800

> I am testing tcp_vegas.c in Linux with the NS-2 TCP-Linux.
> It seems that the ssthresh is not correctly reset to 2 in the
> "tcp_vegas_cong_avoid" function.
> The problem might lead to very unfair behavior among Vegas flows, when
> some flows exit slow start due to loss, not delay.
> 
> Please see the detailed effect at:
> http://www.cs.caltech.edu/%7Eweixl/technical/ns2linux/known_linux/#vegas
> (the section of "Setting of Slow-Start-Threshold")
> 
> A patch I wrote (for Linux 2.6.19-2) is attached.
> Basically, the branch that sets ssthresh to be 2 should be outside the
> condition of (cwnd<=ssthresh).

Please provide a proper "Signed-off-by: " line, see
linux/Documentation/SubmittingPatches for details.

Your patch we not correctly rooted in the tree, the
diff file lines should use paths like:

--- a/net/ipv4/tcp_vegas.c.old     2007-02-01 00:33:55.000000000 -0800
+++ b/net/ipv4/tcp_vegas.c 2007-02-01 00:39:49.000000000 -0800

Again, see linux/Documentation/SubmittingPatches.

Also, GMAIL has corrupted your patch, turning all tab
characters into spaces, so that patch will not apply
properly.

If in doubt, try emailing the patch to yourself and
successfully applying it.

Please fix this up and resubmit, thank you.
