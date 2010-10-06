From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] bonding: fix to rejoin multicast groups immediately
Date: Tue, 05 Oct 2010 20:28:53 -0700 (PDT)
Message-ID: <20101005.202853.39191290.davem@davemloft.net>
References: <20101005220757.GB19931@redhat.com>
	<1286324639-22314-2-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	fubar@us.ibm.com, andy@greyhouse.net
To: fleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57378
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758272Ab0JFD2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 23:28:32 -0400
In-Reply-To: <1286324639-22314-2-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fleitner@redhat.com>
Date: Tue,  5 Oct 2010 21:23:58 -0300

> The IGMP specs states that if the system receives a
> membership report, it shouldn't send another for the
> next minute. However, if a link failure happens right
> after that, the backup slave and the switch connected
> to this slave will not know about the multicast and
> the traffic will hang for about a minute.
> 
> This patch fixes it to rejoin multicast groups immediately
> after a failover restoring the multicast traffic.
> 
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>

Much better commit message :-)

Applied to net-next-2.6
