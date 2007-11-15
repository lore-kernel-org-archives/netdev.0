From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: 2.6.24-rc2-mm1 -- strange apparent network failures
Date: Thu, 15 Nov 2007 10:02:09 +0000
Message-ID: <20071115100209.GB2513@shadowen.org>
References: <20071113175906.497a1a6a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hellhawk.shadowen.org ([80.68.90.175]:1050 "EHLO
	hellhawk.shadowen.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755433AbXKOKDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 05:03:19 -0500
Content-Disposition: inline
In-Reply-To: <20071113175906.497a1a6a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When testing some of the later 2.6.24-rc2-mm1+hotfix combinations on three
of our test systems one job from each batch (1/4) failed.  In each case the
machine appears to have booted normally all the way to a login: prompt.
However in the failed boots the networking though apparently initialised
completely and correctly (as far as I can tell from the console output), is
reported as not responding to ssh connections.  The network interface seems
to have been initialised on the right port, and the ssh daemons started.

Two of the machines are powerpc boxes, the other an older x86_64.
One machine is 4/4 in testing, just one.  Most of the other machines are
still not able to compile this stack so do not contribute to our knowledge.

Any ideas?

-apw
