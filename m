From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [patch] net: ipv6 build fix
Date: Wed, 30 Apr 2008 14:17:41 -0700
Message-ID: <OF82C2A611.73628201-ON8825743B.00745835-8825743B.0074F726@us.ibm.com>
References: <20080430203839.GA19203@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: akpm@linux-foundation.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, torvalds@linux-foundation.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:48007 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758524AbYD3VRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 17:17:55 -0400
In-Reply-To: <20080430203839.GA19203@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo,
        That fix is not correct. Pavel Emelyanov posted a
correct fix to netdev earlier today. Apparently, the context
matched ipv6_getsockopt() in the split version, but those
changes belong in compat_ipv6_getsockopt(), as in Pavel's
fix.
        Since the original patch was correct, I'm not sure
if the fix will have the same problem or not.

                                        +-DLS

