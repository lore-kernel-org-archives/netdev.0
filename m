From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3 net-2.6.25] call FIB rule->action in the correct
 namespace
Date: Sun, 20 Jan 2008 16:47:38 -0800 (PST)
Message-ID: <20080120.164738.01409375.davem@davemloft.net>
References: <478F2933.1000007@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, netdev@vger.kernel.org,
	containers@lists.osdl.org, devel@openvz.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59338
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755730AbYAUAri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 19:47:38 -0500
In-Reply-To: <478F2933.1000007@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 17 Jan 2008 13:08:51 +0300

> FIB rule->action should operate in the same namespace as fib_lookup.
> This is definitely missed right now.
> 
> There are two ways to implement this: pass struct net into another rules
> API call (2 levels) or place netns into rule struct directly. The second
> approach seems better as the code will grow less.
> 
> Additionally, the patchset cleanups struct net from
> fib_rules_register/unregister to have network namespace context at the
> time of default rules creation.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

All 3 patches applied, thanks.
