From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] IPv6 FIB configuration conversions
Date: Thu, 17 Aug 2006 01:40:38 +0200
Message-ID: <20060816234038.106537101@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53665 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932128AbWHPXot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 19:44:49 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Same approach as for IPv4, simplifies the interface
and makes it extendable without breaking the ioctl
interface.

Same memory corruption fixes in RTM_GETROUTE as for IPv4.

