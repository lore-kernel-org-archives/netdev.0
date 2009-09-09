From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [IB] 2.6.31-rc9: SW2HW_EQ failed on Dell R610
Date: Tue, 08 Sep 2009 20:11:20 -0700
Message-ID: <ada1vmgn76v.fsf@cisco.com>
References: <alpine.DEB.1.10.0909081805110.7733@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:12871 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbZIIDLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 23:11:19 -0400
In-Reply-To: <alpine.DEB.1.10.0909081805110.7733@V090114053VZO-1> (Christoph
	Lameter's message of "Tue, 8 Sep 2009 18:06:54 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > The problem with the interrupts is not solved in rc9:

Yes, by the time we got this all resolved, it was already rc8 and I
though 2.6.31 was right around the corner ... the issue didn't seem
severe enough to stick in so late in the cycle, so I queued the patch
for .32 with a cc to stable to get in 2.6.31.1.

The workaround of limiting possible cpus to 16 should be OK for the time
between 2.6.31 and 2.6.31.1.

 - R.
