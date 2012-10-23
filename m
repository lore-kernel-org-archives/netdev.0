From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] pch_gbe: fix CRC errors and improve speed
Date: Tue, 23 Oct 2012 02:31:47 -0400 (EDT)
Message-ID: <20121023.023147.1311051232873090162.davem@davemloft.net>
References: <1350917005-26350-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
	tshimizu818@gmail.com, andy.cress@us.kontron.com,
	erwan.velu@zodiacaerospace.com, agospoda@redhat.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753452Ab2JWGbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 02:31:49 -0400
In-Reply-To: <1350917005-26350-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Mon, 22 Oct 2012 16:43:22 +0200

> This patch series tries to get rid of CRC errors and other instability
> caused by wrong RX_FIFO overrun processing. It also cleans the code a bit.
> 
> Now (without the patch applied) on high number of incoming packets and/or
> stressed system pch_gbe driver reports CRC errors and huge numbers of
> RX_FIFO_ERR (overruns). It also sometimes just freezes (caused by not
> waiting enough on DMA_RX to stop before issuing a reset on MAC_RX logic).
> 
> This patchset removes the unneeded (as per datasheet) MAC_RX reset and
> corrects the processing of RX_FIFO_ERR in pch_gbe_napi_poll().
> 
> With the patchset applied there are no more CRC errors, sane number of
> RX_FIFO_ERR and improved speed/stability. The patchset was tested on
> Informix SYS940X and Kontron Tunnel Creek EG20T on 1gbps direct-connected
> link and different rx/tx descriptors count.

All applied to 'net', thanks.
