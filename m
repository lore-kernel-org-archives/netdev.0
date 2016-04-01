From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Subject: Section 4 No. 9,10 Failed was occurred by IPv6 Ready Logo Conformance
 Test
Date: Fri, 1 Apr 2016 16:31:16 +0900
Message-ID: <56FE23C4.2000706@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym02.jp.fujitsu.com ([211.128.242.41]:22675 "EHLO
	mgwym02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753407AbcDAHbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 03:31:47 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 7F456AC01F7
	for <netdev@vger.kernel.org>; Fri,  1 Apr 2016 16:31:42 +0900 (JST)
Received: from omame (omame.fct.css.fujitsu.com [10.24.14.171])
	by m3051.s.css.fujitsu.com (Postfix) with ESMTP id 7973C9E
	for <netdev@vger.kernel.org>; Fri,  1 Apr 2016 16:31:42 +0900 (JST)
Received: from [10.24.19.86] (ubi86.utsfd.cs.fujitsu.co.jp [10.24.19.86])
	by omame (Postfix) with ESMTPSA id 681F71E0088
	for <netdev@vger.kernel.org>; Fri,  1 Apr 2016 16:31:42 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I tested 4.6-rc1 by IPv6 Ready Logo Core Conformance Test.
4.6-rc1 has some FAILs in Section 4 (RFC 1981: Path MTU Discovery for IP version 6).
I conformed that it was PASSed in 3.14.28 and it was FAILed in 4.1.17.
I will find a patch between 3.14 and 4.1.

IPv6 Ready Logo
https://www.ipv6ready.org/
TAHI Project
http://www.tahi.org/

I ran the IPv6 Ready Logo Core Conformance Test on Intel D510MO (Atom D510).
It is using userland build with yocto project.

Test Environment
Test Specification          : 4.0.6
Tool Version                : REL_3_3_2
Test Program Version        : V6LC_5_0_0
Target Device               : Intel D510MO (Atom D510)

List of FAILs

Section 4: RFC 1981 - Path MTU Discovery for IPv6
- Test v6LC.4.1.6: Receiving MTU Below IPv6 Minimum Link MTU
  - No. 9 Part A: MTU equal to 56
  - No.10 Part B: MTU equal to 1279

Regards,
Yuki Machida
