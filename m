From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [PATCH net-next v2] netxen: explicity handle pause autoneg
 parameter
Date: Sun, 28 Oct 2012 14:39:17 -0500
Message-ID: <13A253B3F9BEFE43B93C09CF75F63CAA827E82A0A2@MNEXMB1.qlogic.org>
References: <1351298393-18172-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Flavio Leitner <fbl@redhat.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:30149 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751058Ab2J1Tjb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2012 15:39:31 -0400
In-Reply-To: <1351298393-18172-1-git-send-email-fbl@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Flavio Leitner [mailto:fbl@redhat.com]
>Sent: Saturday, October 27, 2012 6:10 AM
>To: netdev
>Cc: Sony Chacko; Rajesh Borundia; Ben Hutchings; Flavio Leitner
>Subject: [PATCH net-next v2] netxen: explicity handle pause autoneg
>parameter
>
>The hardware doesn't support controlling pause frames autoneg, so
>report that back correctly to userspace.
>
>Signed-off-by: Flavio Leitner <fbl@redhat.com>
>---
> drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c | 7 +++++++
> 1 file changed, 7 insertions(+)
>
> I don't have the hardware handy to test this, so I appreciate
> if someone could do it.

Yes the hardware does not support pause autoneg.
I have tested the patch.

Acked-by : Rajesh Borundia <rajesh.borundia@qlogic.com>
