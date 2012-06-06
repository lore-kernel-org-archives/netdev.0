From: David Miller <davem@davemloft.net>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire
 X4150(x86) and e1000e
Date: Wed, 06 Jun 2012 10:26:34 -0700 (PDT)
Message-ID: <20120606.102634.778505411377860720.davem@davemloft.net>
References: <20120606174303.0bfc9868.shimoda.hiroaki@gmail.com>
	<20120606092635.00003b61@unknown>
	<1339002304.26966.16.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, shimoda.hiroaki@gmail.com,
	therbert@google.com, denys@visp.net.lb, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37565 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757422Ab2FFR0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 13:26:38 -0400
In-Reply-To: <1339002304.26966.16.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Jun 2012 19:05:04 +0200

> You cant hold a TX completion indefinitely, this breaks BQL but also
> other stuff.

True.
