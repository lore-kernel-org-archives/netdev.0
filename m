From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fixes for DSACK-based undo of cwnd reduction
 during fast recovery
Date: Mon, 14 Nov 2011 15:23:59 -0500 (EST)
Message-ID: <20111114.152359.1131974895743731960.davem@davemloft.net>
References: <1320775631-16341-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, ycheng@google.com, therbert@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55483 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637Ab1KNUYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 15:24:14 -0500
In-Reply-To: <1320775631-16341-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Tue,  8 Nov 2011 13:07:11 -0500

> (2) When the ACK field is below snd_una (the "old_ack" goto label),
> process any DSACKs and try to send out more packets based on
> newly-SACKed packets.

This seems dubious.

An older ACK should not have more uptodate SACK information than a newer
ACK.
