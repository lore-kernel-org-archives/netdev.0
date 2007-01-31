From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] Seperate DSACK from SACK fast path
Date: Wed, 31 Jan 2007 12:49:25 -0800 (PST)
Message-ID: <20070131.124925.85416509.davem@davemloft.net>
References: <20070129071339.24050.21052.sendpatchset@galon.ev-en.org>
	<20070129071344.24050.14971.sendpatchset@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44285
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030570AbXAaUtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 15:49:25 -0500
In-Reply-To: <20070129071344.24050.14971.sendpatchset@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Mon, 29 Jan 2007 09:13:44 +0200

> +	for (i = 0; i < num_sacks; i++) {
> +		__be32 start_seq = sp[i].start_seq;
> +		__be32 end_seq = sp[i].end_seq;

This is not sufficient, you have to also fix up the type
of the recv_sack_cache[] array entries in struct tcp_sock
to be struct tcp_sack_block_wire.
