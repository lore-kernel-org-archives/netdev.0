From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: e100 and eepro100
Date: Sat, 28 Apr 2007 00:52:30 +0900 (JST)
Message-ID: <20070428.005230.105332667.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, usagi-core@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33271 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756034AbXD0Pw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 11:52:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

I heard that there is a plan to remove eepro100 driver from kernel,
but from the IPv6 point of view, there are still some issues with
e100 driver, which does not exist in eepro100.

We are using some e100/eepro100 devices, and we have found that
we cannot pass the Conformance Test with e100 but with eepro100.

We have been having no chance to debug this issue so far, but
I guess there are some bugs in link detection code in e100.

Regards,

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
