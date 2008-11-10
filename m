From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [1/3] IRDA: Create new field tx_extra in skbuff
Date: Mon, 10 Nov 2008 19:55:44 +0300
Message-ID: <20081110165544.GB19804@ioremap.net>
References: <49185CBD.2040601@ceibo.fiec.espol.edu.ec> <20081110163546.GA19804@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: irda-users@lists.sourceforge.net, netdev@vger.kernel.org
To: Alex =?utf-8?B?VmlsbGFjw63CrXM=?= Lasso
	<avillaci@ceibo.fiec.espol.edu.ec>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:39023 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753793AbYKJQzs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2008 11:55:48 -0500
Content-Disposition: inline
In-Reply-To: <20081110163546.GA19804@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 10, 2008 at 07:35:46PM +0300, Evgeniy Polyakov (zbr@ioremap.net) wrote:
> What exactly should be carried in that area?

It is struct irda_skb_cb, which contains qos and other bits of
intormation about how to transfer data, which are in turn obtained from
various _cb IRDA structures, which I tracked upto to for example
lsap_cb, which exists in the hash table. Do others also accessible via
similar mechanism? Can that data be stored on per-device basis like
ethernet checksum/offloading parameters (for example like LRO is done)?

-- 
	Evgeniy Polyakov
