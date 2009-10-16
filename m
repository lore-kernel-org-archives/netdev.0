From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 0/3] qlge: Size RX buffers based on MTU.
Date: Fri, 16 Oct 2009 13:15:33 -0700
Message-ID: <1255724136-27264-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:55516 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbZJPUVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 16:21:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Change RX large buffer size based on MTU. If pages are larger
than the MTU the page is divided up into multiple chunks and passed to
the hardware.  When pages are smaller than MTU each RX buffer can
contain be comprised of up to 2 pages.

Dave,
These patches are interdependent.

