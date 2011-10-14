From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: EHEA updates
Date: Fri, 14 Oct 2011 12:30:57 -0300
Message-ID: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:51688 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933088Ab1JNPb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:31:29 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id p9ECX4Cb011560
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 09:33:04 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EFZ1Kt1294722
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:35:02 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EFVHhI007676
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:31:17 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a rebase of Anton's patches on top of net-next HEAD, commit
7ae60b3. Besides the conflicts with the latest patches, some trivia were
fixed as suggested.

Ben Hutchings' suggestions about doing packet split and NAPI fixes were
taken into consideration, but not done on this round.

The result was tested between two LPARs and also using a switch, with
ICMP and TCP tests.
