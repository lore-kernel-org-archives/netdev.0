From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 0/3] qlge: EEH fixes.
Date: Wed,  3 Feb 2010 09:24:10 -0800
Message-ID: <1265217853-26959-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:1451 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932706Ab0BCRbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 12:31:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Move asic reset from io_resume() to io_reset.
2) Fix case where close() can hang if eeh did not recover.
3) Fix stall in eeh recovery process.


