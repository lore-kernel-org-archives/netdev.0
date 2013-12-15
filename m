From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next 0/3] IPComp fixes
Date: Sun, 15 Dec 2013 17:19:51 +0800
Message-ID: <1387099194-18540-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62951 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784Ab3LOJUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 04:20:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset includes bug fix focusing on IPComp mainly, which addresses
IPComp Compression Parameter Index(CPI, 16bits of 32bits SPI value) problem.

And other issue is the compression part, undesirable packet will not be
compressed, and then send into wire, this packet will be dropped by policy
checking in the receiver side.

v2:
  Patch1: Clean up align issue from v1.
  Patch2: Introduce verify_userspi_info for pkfey and netlink interface
          to share code.
  Patch3: Add Documentation/networking/ipsec.txt to document known issues. 

Fan Du (3):
  xfrm: check user specified spi for IPComp
  xfrm: export verify_userspi_info for pkfey and netlink interface
  xfrm: Add file to document IPsec corner case

 Documentation/networking/ipsec.txt |   40 ++++++++++++++++++++++++++++++++++++
 include/net/xfrm.h                 |    1 +
 net/key/af_key.c                   |    6 ++++++
 net/xfrm/xfrm_state.c              |   24 ++++++++++++++++++++++
 net/xfrm/xfrm_user.c               |   29 ++++----------------------
 5 files changed, 75 insertions(+), 25 deletions(-)
 create mode 100644 Documentation/networking/ipsec.txt

-- 
1.7.9.5
