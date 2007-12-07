From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 0/8] bonding: Several fixes, new hash mode
Date: Thu,  6 Dec 2007 23:40:27 -0800
Message-ID: <11970132353950-git-send-email-fubar@us.ibm.com>
Cc: jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:50907 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbXLGHkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 02:40:37 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB77earO009077
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 02:40:36 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB77eadh130976
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 00:40:36 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB77easv017964
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 00:40:36 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Patch series to fix some bugs, fix coding style, and add a new
hash mode for balance-xor/802.3ad modes.

	Jeff: please apply to upstream.

	Patch 8 should arguably go in to 2.6.24, as it's a bug in the
locking fixes added there and can cause an oops; is it too late for that?

[PATCH 1/8] bonding: Remove trailing NULs from sysfs interface.
[PATCH 2/8] bonding: Return nothing for not applicable values
[PATCH 3/8] bonding: Purely cosmetic: rename a local variable
[PATCH 4/8] bonding: Coding style: break line after the if condition
[PATCH 5/8] bonding: Allow setting and querying xmit policy regardless of mode
[PATCH 6/8] bonding: Fix time comparison
[PATCH 7/8] bonding: Add new layer2+3 hash for xor/802.3ad modes
[PATCH 8/8] bonding: Fix race at module unload

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
