From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next]r8169:Correct size from dma_alloc_coherent
 Maximum size register with size argument from dma_alloc_coherent old
 variable R8169_RX_RING_BYTES return to much value 17000 instead of value
 of rx_buf_sz, another issue is on rtl8169_init_ring func, Tx buffer and Rx
 buffer have same number off descriptors NUM_RX_DESC, not others values.
Date: Sun, 26 Jul 2015 15:55:47 -0700 (PDT)
Message-ID: <20150726.155547.1030770223246335704.davem@davemloft.net>
References: <1437945567-2495-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: corcodel.marian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866AbbGZWzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 18:55:50 -0400
In-Reply-To: <1437945567-2495-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This, again, is improperly submitted.

Again, your entire commit message is in the subject line and this is
not what we want.

This constant wave of badly formed patch submissions is extremely
frustrating, and whether you realise it or not your improper
submissions are consuming a large amount of valuable developer time.
