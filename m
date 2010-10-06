From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] bonding: rejoin multicast groups on VLANs
Date: Tue, 05 Oct 2010 20:28:40 -0700 (PDT)
Message-ID: <20101005.202840.183059128.davem@davemloft.net>
References: <20101005220757.GB19931@redhat.com>
	<1286324639-22314-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	fubar@us.ibm.com, andy@greyhouse.net
To: fleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57370
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756918Ab0JFD2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 23:28:19 -0400
In-Reply-To: <1286324639-22314-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fleitner@redhat.com>
Date: Tue,  5 Oct 2010 21:23:57 -0300

> During a failover, the IGMP membership is sent to update
> the switch restoring the traffic, but it misses groups added
> to VLAN devices running on top of bonding devices.
> 
> This patch changes it to iterate over all VLAN devices
> on top of it sending IGMP memberships too.
> 
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>

This seems to address Andy's feedback properly, and otherwise
looks good to me, so applied to net-next-2.6
