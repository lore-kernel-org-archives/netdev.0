From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2][NETNS][DST] add the network namespace pointer in
 dst_ops
Date: Fri, 18 Jan 2008 03:58:20 -0800 (PST)
Message-ID: <20080118.035820.151400695.davem@davemloft.net>
References: <20080116145416.844293640@localhost.localdomain>
	<20080116150733.443636890@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, den@openvz.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56163
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753141AbYARL6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 06:58:19 -0500
In-Reply-To: <20080116150733.443636890@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Wed, 16 Jan 2008 15:54:18 +0100

> The network namespace pointer can be stored into the dst_ops structure.
> This is usefull when there are multiple instances of the dst_ops for a
> protocol. When there are no several instances, this field will be never
> used in the protocol. So there is no impact for the protocols which do
> implement the network namespaces.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied, thanks.
