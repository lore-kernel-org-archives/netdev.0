From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 0/8] qlge: Add firmware coredump functionality.
Date: Fri, 15 Jan 2010 15:31:26 -0800
Message-ID: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:37681 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758652Ab0AOXiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 18:38:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dump all regsiters and on-chip RAM when a fatal firmware error is
encountered.  This feature is turn OFF by default but can be turned on
with a module parameter.

Dave,

The constant definitions have been cleaned up with aligned tabs per your
request.  The dump function and it's memory allocation are now turned
OFF by default.
I've added/expanded register definitions to aid in dump process which
gets rid of the literal numeric constants.

Thanks, Ron

