From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v5] can: Unify droping of invalid tx skbs
 and netdev stats
Date: Tue, 12 Jan 2010 02:00:53 -0800 (PST)
Message-ID: <20100112.020053.135150058.davem@davemloft.net>
References: <4B4C420C.1040308@hartkopp.net>
	<4B4C47A0.6020304@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: socketcan@hartkopp.net, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org, mkl@pengutronix.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59307
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753939Ab0ALKAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 05:00:44 -0500
In-Reply-To: <4B4C47A0.6020304@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Tue, 12 Jan 2010 10:57:52 +0100

> Oliver Hartkopp wrote:
>> To prevent the CAN drivers to operate on invalid socketbuffers the skbs are
>> now checked and silently dropped at the xmit-function consistently.
>> 
>> Also the netdev stats are consistently using the CAN data length code (dlc)
>> for [rx|tx]_bytes now.
>> 
>> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
> 
> Acked-by: Wolfgang Grandegger <wg@grandegger.com>

Applied, thanks!
