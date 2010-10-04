From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Revert "ipv4: Make INET_LRO a bool instead of
 tristate."
Date: Sun, 03 Oct 2010 19:56:18 -0700 (PDT)
Message-ID: <20101003.195618.193723845.davem@davemloft.net>
References: <1286156262.3916.213.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60107
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751328Ab0JDCz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Oct 2010 22:55:57 -0400
In-Reply-To: <1286156262.3916.213.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 04 Oct 2010 02:37:42 +0100

> You made the change I want to revert in response to
> <http://article.gmane.org/gmane.linux.kernel/825646>.  The real problem
> with its configuration is actually that CONFIG_INET is not set but
> CONFIG_INET_LRO=m, and the fix is to make CONFIG_PASEMI_MAC depend on
> CONFIG_INET.

Ben, you can't just revert this by itself.

That knowingly breaks the build.

If you want the tristate back, you must do it after or at the
same time as fixing the driver deps.

Thanks.
