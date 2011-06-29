From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]rionet: fix NULL pointer dereference in rionet_remove
Date: Wed, 29 Jun 2011 05:57:59 -0700 (PDT)
Message-ID: <20110629.055759.1556521651128595877.davem@davemloft.net>
References: <4e098bf5.87f62a0a.4c71.571a@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mporter@kernel.crashing.org,
	jj@chaosbits.net, cmdkhh@gmail.com
To: synmyth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755727Ab1F2M6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 08:58:08 -0400
In-Reply-To: <4e098bf5.87f62a0a.4c71.571a@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yinglin Luan <synmyth@gmail.com>
Date: Sun, 26 Jun 2011 12:12:12 +0800

> Function rionet_remove initializes local variable 'ndev' to NULL
> and do nothing changes before the call to unregister_netdev(ndev),
> this could cause a NULL pointer dereference.
> 
> Reported-by: Jesper Juhl <jj@chaosbits.net>
> Signed-off-by: Yinglin Luan <synmyth@gmail.com>

Applied.
