From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2][NETNS][DST] dst: pass the dst_ops as parameter to
 the gc functions
Date: Fri, 18 Jan 2008 03:57:26 -0800 (PST)
Message-ID: <20080118.035726.246361573.davem@davemloft.net>
References: <20080116145416.844293640@localhost.localdomain>
	<20080116150724.711756326@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, den@openvz.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56516
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751361AbYARL5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 06:57:25 -0500
In-Reply-To: <20080116150724.711756326@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Wed, 16 Jan 2008 15:54:17 +0100

> The garbage collection function receive the dst_ops structure as
> parameter. This is useful for the next incoming patchset because
> it will need the dst_ops (there will be several instances) and 
> the network namespace pointer (contained in the dst_ops).
> 
> The protocols which do not take care of the namespaces will not
> be impacted by this change (expect for the function signature),
> they do just ignore the parameter.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied.
