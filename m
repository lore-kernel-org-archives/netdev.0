From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT 0/5] sky2: suspend/resume patchlets
Date: Tue, 13 Jun 2006 17:17:26 +0900
Message-ID: <20060613081726.695812000@localhost.localdomain>
Cc: linus@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18155 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750750AbWFMIUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 04:20:33 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There were a several problems buried in suspend/resume. The real
failure was caused by the idle timer not being stopped/restarted.
But several other races, and cleanups were needed.

Since I don't have a machine that will suspend successfully with
that hardware, I can't test it.

--

