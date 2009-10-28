From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-velocity: Remove private device list
Date: Wed, 28 Oct 2009 04:02:06 -0700 (PDT)
Message-ID: <20091028.040206.244368976.davem@davemloft.net>
References: <1256501329.3136.109.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51934
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752397AbZJ1LBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 07:01:45 -0400
In-Reply-To: <1256501329.3136.109.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 25 Oct 2009 20:08:49 +0000

> via-velocity maintains a list of its devices in order to determine
> whether a netdev notification applies to one of them.  That can be
> determined simply by checking the netdev_ops pointer, so the list can
> be removed.
> 
> Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Looks good to me, applied to net-next-2.6
