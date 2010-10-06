From: Rogerio Pimentel <rogerio.pimentel@freescale.com>
Subject: Segmentation fault when using ping6
Date: Wed, 6 Oct 2010 17:27:29 -0300
Message-ID: <4CACDBB1.9050305@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe005.messaging.microsoft.com ([65.55.88.15]:15820 "EHLO
	TX2EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759625Ab0JFUWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 16:22:32 -0400
Received: from mail106-tx2 (localhost.localdomain [127.0.0.1])	by
 mail106-tx2-R.bigfish.com (Postfix) with ESMTP id 721EA1920302	for
 <netdev@vger.kernel.org>; Wed,  6 Oct 2010 20:22:31 +0000 (UTC)
Received: from TX2EHSMHS044.bigfish.com (unknown [10.9.14.246])	by
 mail106-tx2.bigfish.com (Postfix) with ESMTP id 49D391708058	for
 <netdev@vger.kernel.org>; Wed,  6 Oct 2010 20:22:31 +0000 (UTC)
Received: from az33smr01.freescale.net (az33smr01.freescale.net
 [10.64.34.199])	by az33egw02.freescale.net (8.14.3/8.14.3) with ESMTP id
 o96KMTZx007633	for <netdev@vger.kernel.org>; Wed, 6 Oct 2010 13:22:29 -0700
 (MST)
Received: from zbr05exm41.fsl.freescale.net (zbr05exm41.am.freescale.net
 [10.29.240.246])	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id
 o96KMSup022132	for <netdev@vger.kernel.org>; Wed, 6 Oct 2010 15:22:28 -0500
 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm having a "segmentation fault" problem when using ping6.

When testing on ARM9 platforms (i.MX25 and i.MX27), it returns the error:

root@freescale ~$ ping6 ::1
PING ::1 (::1): 56 data bytes
Segmentation fault

When testing on ARM11 and ARM Cortex A8 platforms (i.MX31 and i.MX51), 
it works:

root@freescale ~$ ping6 ::1
PING ::1 (::1): 56 data bytes
64 bytes from ::1: seq=0 ttl=64 time=0.331 ms
64 bytes from ::1: seq=1 ttl=64 time=0.214 ms
64 bytes from ::1: seq=2 ttl=64 time=0.176 ms
64 bytes from ::1: seq=3 ttl=64 time=0.155 ms

On all cases, I'm using Linux Kernel 2.6.35 (from Mainline) and Busybox 
1.15.0

Does anybody have any idea?

Thanks in advance,

Rogerio Pimentel


