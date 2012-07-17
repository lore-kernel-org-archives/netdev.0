From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Fix enforcement of multicast hash_max limit
Date: Mon, 16 Jul 2012 22:59:46 -0700 (PDT)
Message-ID: <20120716.225946.92115650026078905.davem@davemloft.net>
References: <417e2d4ff99d88014f288e9924c5a45d4650f474.1341995313.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419Ab2GQF7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 01:59:47 -0400
In-Reply-To: <417e2d4ff99d88014f288e9924c5a45d4650f474.1341995313.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 11 Jul 2012 10:29:19 +0200

> The hash size is doubled when it needs to grow and compared against
> hash_max. The >= comparison will limit the hash table size to half
> of what is expected i.e. the default 512 hash_max will not allow
> the hash table to grow larger than 256.
> 
> Also print the hash table limit instead of the desirable size when
> the limit is reached.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied to net-next, thanks Thomas.
