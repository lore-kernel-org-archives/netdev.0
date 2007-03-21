From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/3] [PATCHSET] netlink error management
Date: Thu, 22 Mar 2007 00:18:01 +0100
Message-ID: <20070321231801.342849239@lsx.localdomain>
Cc: netdev@vger.kernel.org, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:50333 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750821AbXCUXVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 19:21:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series of patches simplifies the error management and
signalization of dump starts of netlink_run_queue() message
handlers. It touches a fair bit of nfnetlink code as the
error pointer has been passed on to subsystems.

