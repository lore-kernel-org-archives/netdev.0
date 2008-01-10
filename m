From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-2.6.25 00/10][NETNS][IPV6] make sysctl per
 namespace - V3
Date: Thu, 10 Jan 2008 03:15:44 -0800 (PST)
Message-ID: <20080110.031544.259471083.davem@davemloft.net>
References: <20080109164533.695191040@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58618
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753985AbYAJLPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 06:15:45 -0500
In-Reply-To: <20080109164533.695191040@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Wed, 09 Jan 2008 17:45:33 +0100

> The following patchset makes the ipv6 sysctl to handle multiple
> network namespaces. Each instance of a network namespace as its own
> set of sysctl values, that means the behavior of the ipv6 stack can be
> different depending on the sysctl values setup in the different
> network namespaces.

I applied all of this to net-2.6.25 but what a rough half hour
it was :-/

Starting at patch #5 there were tons of "space before tab" errors.
And as I fixed them up, this made subsequent patches need rediffing
since the contextual lines in patches after #5 needed the whitespace
fixed up as well.

I didn't push this back to you because this was already the 3rd round,
but please show me some love and check this stuff out before
submission.  GIT gives you effective ways to verify the whitespace
without even applying the patch.

~davem/bin/pcheck:

#!/bin/sh
set -x
git apply --check --whitespace=error-all $1
