From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] packet: Don't check frames_per_block against negative
 values
Date: Tue, 17 Nov 2015 15:26:29 -0500 (EST)
Message-ID: <20151117.152629.1008103506581635101.davem@davemloft.net>
References: <1447753116-11831-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbbKQU0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 15:26:30 -0500
In-Reply-To: <1447753116-11831-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 17 Nov 2015 10:38:36 +0100

> rb->frames_per_block is an unsigned int, thus can never be negative.
> 
> Also fix spacing in the calculation of frames_per_block.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
