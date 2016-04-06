From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] net: bcmgenet: fix dmadesc_set()
Date: Wed, 06 Apr 2016 16:09:39 -0400 (EDT)
Message-ID: <20160406.160939.1689240854039564888.davem@davemloft.net>
References: <1459815001-91703-1-git-send-email-pgynther@google.com>
	<1459815001-91703-3-git-send-email-pgynther@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbcDFUJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 16:09:45 -0400
In-Reply-To: <1459815001-91703-3-git-send-email-pgynther@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Mon,  4 Apr 2016 17:10:01 -0700

> dmadesc_set() is used for setting the Tx buffer DMA address, length,
> and status bits on a Tx ring descriptor when a frame is being Tx'ed.
> 
> Always set the Tx buffer DMA address first, before updating the length
> and status bits, i.e. giving the Tx descriptor to the hardware.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Applied.
