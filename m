From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 0/8 2.6.28] cxgb3 - driver update
Date: Wed, 08 Oct 2008 17:32:40 -0700
Message-ID: <48ED5128.4070004@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>,
	David Miller <davem@davemloft.net>
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:27072 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754054AbYJIAcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 20:32:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[cc-ing Dave in Jeff's absence]

Hi Jeff,

I'm submitting 8 update patches against net-next-2.6 for inclusion in 
2.6.28.
Here is a brief description of the patch series:
- reset the chip and bring ports back up when a fatal error occurs
- set multiple queues per default in MSI-X mode

[the following patches re-organize the PHY related code,
 and add more PHYs support]
- account for phy reset errors
- simplify PHY related structures
- add flexibility in PHY interrupt support
- introduce generic code for PHY interrupt support
- add support for Aeluros 2005 PHY
- add support for optical Vitess 8211 phy.

Cheers,
Divy
