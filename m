From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [RFC 0/2] [IPV6] ADDRCONF: IPv6 configurable Default Address
 Selection support (TAKE 2)
Date: Tue, 30 Oct 2007 14:52:30 +0900 (JST)
Message-ID: <20071030.145230.131448757.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:36845 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751AbXJ3FwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 01:52:20 -0400
Received: from localhost (localhost [127.0.0.1])
	by yue.st-paulia.net (Postfix) with ESMTP id A9E6633B46
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 14:52:32 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the 2nd RFC for supporting configurable IPv6 Default Address Selection
policy (RFC3484) based on 2.6.24-rc1.
This is intended for 2.6.25.

Major changes:
	- Use rtnetlink instead of ioctl/procfs.
	- Use RCU.

Git tree is available at the branch named 2.6.24-rc1-addrlabel-20071030 at
	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git

iproute2 is available at the branch named addrlabel-20071030 at
	git://git.linux-ipv6.org/gitroot/yoshfuji/iproute2-dev.git

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
