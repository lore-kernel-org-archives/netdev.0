From: Roland Dreier <rdreier@cisco.com>
Subject: Re: intermittant petabyte usage reported with broadcom nic
Date: Thu, 12 Apr 2007 16:15:26 -0700
Message-ID: <adaslb5dw1d.fsf@cisco.com>
References: <20070402014319.GA8345@zip.com.au>
	<20070402001300.3b66007d.akpm@linux-foundation.org>
	<20070412225249.GU8345@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: CaT <cat@zip.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:6924 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262AbXDLXPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 19:15:40 -0400
In-Reply-To: <20070412225249.GU8345@zip.com.au> (cat@zip.com.au's message of "Fri, 13 Apr 2007 08:52:49 +1000")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Apr  9 06:19:04 '  eth0:14250798570591813804 2284720007938 18638    0    0 18638          0  27375938 1556640980159 3345714490    0    0    0     0       0          0 '

One odd thing is that crazy number 14250798570591813804 is
c5c501cbc5c500ac in hex.  I dunno what the significant of the 0xc5 bit
pattern is though...

The other line has 220898233988841368, which is 0x310c9c6006a7f98, not
nearly so regular a patter.

I don't think I'm helping much...
