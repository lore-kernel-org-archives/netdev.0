From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [NET] fib_rules: Mark rules detached from the
 device
Date: Mon, 26 Mar 2007 17:38:22 -0700 (PDT)
Message-ID: <20070326.173822.78710353.davem@davemloft.net>
References: <20070326235450.756924134@lsx.localdomain>
	<20070326235713.610933740@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33428
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932130AbXC0AiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 20:38:23 -0400
In-Reply-To: <20070326235713.610933740@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 27 Mar 2007 01:54:52 +0200

> Rules which match against device names in their selector can
> remain while the device itself disappears, in fact the device
> doesn't have to present when the rule is added in the first
> place. The device name is resolved by trying when the rule is
> added and later by listening to NETDEV_REGISTER/UNREGISTER
> notifications.
> 
> This patch adds the flag FIB_RULE_DEV_DETACHED which is set
> towards userspace when a rule contains a device match which
> is unresolved at the moment. This eases spotting the reason
> why certain rules seem not to function properly.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Yep, this should make failure diagnosis easier.

Applied to net-2.6.22, thanks.
