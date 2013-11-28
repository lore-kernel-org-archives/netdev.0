From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next 0/3] IPComp fixes
Date: Thu, 28 Nov 2013 10:52:38 +0800
Message-ID: <1385607161-27597-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:46958 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758650Ab3K1Cws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 21:52:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset includes bug fix focusing on IPComp mainly, which addresses
IPComp Compression Parameter Index(CPI, 16bits of 32bits SPI value) problem.

And other issue is the compression part, undesirable packet will not be
compressed, and then send into wire, this packet will be dropped by policy
checking in the receiver side.

Fan Du (3):
  xfrm: check user specified spi for IPComp
  xfrm: clamp down spi range for IPComp when allocating spi
  xfrm: Restrict "level use" for IPComp configuration

 net/key/af_key.c      |    6 ++++++
 net/xfrm/xfrm_state.c |   13 +++++++++++++
 net/xfrm/xfrm_user.c  |    7 ++++++-
 3 files changed, 25 insertions(+), 1 deletion(-)

-- 
1.7.9.5
