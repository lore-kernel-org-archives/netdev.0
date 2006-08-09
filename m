From: David Miller <davem@davemloft.net>
Subject: [PATCHSET]: Dymamic route cache hash sizing
Date: Wed, 09 Aug 2006 00:49:20 -0700 (PDT)
Message-ID: <20060809.004920.59469729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9197
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964859AbWHIHtc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 03:49:32 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id CFEA1AE43C3
	for <netdev@vger.kernel.org>; Wed,  9 Aug 2006 00:49:20 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ok, I threw something together.  Patches coming.

The initial algorithm is very dumb, but the code seems to work well at
least on my systems.

I encourage folks to send me fixes to the growing and shrinking logic
as that's the only part that really needs any work.

The patches are against net-2.6.19
