From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 0/4]: Fix several errors in extension header handling.
Date: Wed, 19 Apr 2006 00:20:45 +0900 (JST)
Message-ID: <20060419.002045.85775401.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:65298 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932270AbWDRPSF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 11:18:05 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Following changesets fix several errors in extension header handling.
I'd propose to push them (except 4/4, maybe) to -stable.

[PATCH 1/4] [IPV6]: Ensure to have hop-by-hop options in our header of &sk_buff.
[PATCH 2/4] [IPV6] XFRM: Don't use old copy of pointer after pskb_may_pull().
[PATCH 3/4] [IPV6] XFRM: Fix decoding session with preceding extension header(s).
[PATCH 4/4] [IPV6]: Clean up hop-by-hop options handler.

Regards,

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
