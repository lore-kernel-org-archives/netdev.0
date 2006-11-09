From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] packet mark & fib rules work
Date: Thu, 09 Nov 2006 12:27:35 +0100
Message-ID: <20061109112735.577771022@lsx.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:2256 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932813AbWKILdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 06:33:31 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Renames nfmark to mark and remove the dependency on netfilter
to ease usage by all subsystems. Also removes all the unneeded
config options to enable routing by fwmark, it can be safely
enabled by default.

Moves mark selector code from per protocol part into the generic
part and adds support for inverting selectors.

