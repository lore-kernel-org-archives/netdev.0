From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix to rejoin multicast groups immediately
Date: Tue, 05 Oct 2010 00:13:38 -0700 (PDT)
Message-ID: <20101005.001338.52208103.davem@davemloft.net>
References: <1285744327-1194-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37898
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757610Ab0JEHNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 03:13:17 -0400
In-Reply-To: <1285744327-1194-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fleitner@redhat.com>
Date: Wed, 29 Sep 2010 04:12:07 -0300

> It should rejoin multicast groups immediately when
> the failover happens to restore the multicast traffic.
> 
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>

I suspect the IGMPv3 handling via a delayed action, as is currently
implemented, is on purpose and is done so to follow the specification
of the IGMPv3 RFCs.

Therefore you have to explain why your new behavior is so desirable
and in particular why something as undesirable as violating the RFCs
is therefore warranted.
