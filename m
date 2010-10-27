From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 0/4] RFC: tipc int vs size_t fixes
Date: Wed, 27 Oct 2010 15:13:32 -0400
Message-ID: <1288206816-23025-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	drosenberg@vsecurity.com, jon.maloy@ericsson.com,
	security@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40307 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755340Ab0J0TPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 15:15:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a starting point for fixing up the mix of int vs. size_t
usage that Dan spotted in TIPC as being open to possible exploits.

Open questions I had remaining with these patches were whether we could
trim out some of the unrequired casts, and whether we wanted to use a
size_t for everything that at any time was based on or compared to
an iov_len, including all instances of num_sect, when things like
iov_length() in <linux/uio.h> use unsigned long for looping over segments.
Also, whether we should give up at INT_MAX or LONG_MAX...

Please suggest changes as required, and I'll integrate them into this
pass1 of draft of patches from Al and resend as required until we've
got a final acceptable solution.

Thanks,
Paul.
