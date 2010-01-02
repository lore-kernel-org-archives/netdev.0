From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 0/3] qlge: Performance changes for qlge.
Date: Sat,  2 Jan 2010 12:37:41 -0800
Message-ID: <1262464664-14996-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:37005 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912Ab0ABUp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2010 15:45:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Currently qlge splits headers into a separate buffer so they can
be re-aligned on a 2-byte boundary.  This is done to avoid
exceptions thrown on certain platforms when headers are processed.
To avoid the overhead of re-aligning headers, we turn on the split 
header/realign configuration only when the platform requires it.
This allows usage of the gro-frags interface on platforms that do
not require 32 bit aligned headers.



