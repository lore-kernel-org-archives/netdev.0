From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: call fanout_release, while UNREGISTERING a
 netdev
Date: Thu, 06 Oct 2016 20:50:52 -0400 (EDT)
Message-ID: <20161006.205052.1380596858044266995.davem@davemloft.net>
References: <1475676774-18726-1-git-send-email-anoob.soman@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: anoob.soman@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43436 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936399AbcJGAuz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 20:50:55 -0400
In-Reply-To: <1475676774-18726-1-git-send-email-anoob.soman@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anoob Soman <anoob.soman@citrix.com>
Date: Wed, 5 Oct 2016 15:12:54 +0100

> If a socket has FANOUT sockopt set, a new proto_hook is registered
> as part of fanout_add(). When processing a NETDEV_UNREGISTER event in
> af_packet, __fanout_unlink is called for all sockets, but prot_hook which was
> registered as part of fanout_add is not removed. Call fanout_release, on a
> NETDEV_UNREGISTER, which removes prot_hook and removes fanout from the
> fanout_list.
> 
> This fixes BUG_ON(!list_empty(&dev->ptype_specific)) in netdev_run_todo()
> 
> Signed-off-by: Anoob Soman <anoob.soman@citrix.com>

Applied and queued up for -stable, thanks.
