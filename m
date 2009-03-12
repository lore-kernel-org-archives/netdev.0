From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 0/4] sctp: clean-ups and fixes
Date: Thu, 12 Mar 2009 15:49:16 -0400
Message-ID: <1236887360-1904-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:45282 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326AbZCLTtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 15:49:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

This a small set of fixes in sctp:
 1) clean up and simplify sctp listening code.
 2) fix ASCONF indication in INIT-ACK.
 3) send FORWARD TSN chunks only when peer supports the extension.
 4) include Adaptation Indication parameter only when user set it.

Thanks
-vlad
