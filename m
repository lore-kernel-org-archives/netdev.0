From: David Miller <davem@davemloft.net>
Subject: Re: [2.6.25-rc5-mm1] regression: cannot run Postfix sendmail
 command as non-root
Date: Wed, 19 Mar 2008 15:49:47 -0700 (PDT)
Message-ID: <20080319.154947.78332548.davem@davemloft.net>
References: <47D98510.60801@imap.cc>
	<939d53060803191052o2f43b75cu426d51f9f24e2a46@mail.gmail.com>
	<20080319141608.ede86a86.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben.thery@gmail.com, tilman@imap.cc, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org,
	dlezcano@fr.ibm.com, xemul@openvz.org, rjw@sisk.pl,
	ebiederm@xmission.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43102
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1162517AbYCSWtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 18:49:32 -0400
In-Reply-To: <20080319141608.ede86a86.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 19 Mar 2008 14:16:08 -0700

> Although this is advertised as a 2.6.25-rc5-mm1 problem, I assume the
> regression is also in mainline? 2.6.25-rc6?

It is in 2.6.25-rc6, correct.

If Pavel or someone else doesn't produce a good fix soon
I'll revert the guilty change as this bug is worse than
the problem that changeset fixes.
