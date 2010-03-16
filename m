From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: Fix oops in pppol2tp_xmit
Date: Tue, 16 Mar 2010 14:29:29 -0700 (PDT)
Message-ID: <20100316.142929.134605072.davem@davemloft.net>
References: <20100316164631.21463.99826.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41940
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760044Ab0CPV3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 17:29:07 -0400
In-Reply-To: <20100316164631.21463.99826.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Tue, 16 Mar 2010 16:46:31 +0000

> When transmitting L2TP frames, we derive the outgoing interface's UDP
> checksum hardware assist capabilities from the tunnel dst dev. This
> can sometimes be NULL, especially when routing protocols are used and
> routing changes occur. This patch just checks for NULL dst or dev
> pointers when checking for netdev hardware assist features.
 ...
> Signed-off-by: James Chapman <jchapman@katalix.com>

Applied.
