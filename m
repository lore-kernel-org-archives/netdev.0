From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Avoid overhead when no custom FIB rules are
 installed.
Date: Thu, 05 Jul 2012 23:39:10 -0700 (PDT)
Message-ID: <20120705.233910.1053967576670824373.davem@davemloft.net>
References: <20120705.223142.2236039770560842377.davem@davemloft.net>
	<1341553282.3265.49.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33629 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230Ab2GFGjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 02:39:13 -0400
In-Reply-To: <1341553282.3265.49.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Jul 2012 07:41:22 +0200

> Hmm, this seems quite big to be inlined ?

It's about the same size as the non-rule case.
