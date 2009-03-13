From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-next 0/10] cxgb3: driver updates
Date: Fri, 13 Mar 2009 00:13:56 -0700
Message-ID: <49BA07B4.30706@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "David S. Miller" <davem@davemloft.net>,
	Linux Network Development list <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:27577 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbZCMHNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 03:13:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I=E2=80=99m submitting 10 patches targeted for net-next-2.6.

Here is a brief description of the patch series:
- ring receive rings door bells less aggressively
- drop page reference when dma mapping fails
- fix skb truesize when coalescing fragments of a jumbo frame
- eliminate a cache miss in the GRO section of the driver
- segregate Rx and Tx credit reclaim timers
- poll for HW alert status when intrs would happen too frequently
- update the xgmac hang workaround for the chip's rev 3
- detect mac link faults
- update the FW rev to 7.1
- update the driver rev to 1.1.2

Cheers,
Divy
