From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net: bcmgenet: cleanup for bcmgenet_xmit()
Date: Wed, 06 Apr 2016 16:09:28 -0400 (EDT)
Message-ID: <20160406.160928.750308962283056120.davem@davemloft.net>
References: <1459815001-91703-1-git-send-email-pgynther@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753161AbcDFUJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 16:09:30 -0400
In-Reply-To: <1459815001-91703-1-git-send-email-pgynther@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Mon,  4 Apr 2016 17:09:59 -0700

> 1. Readability: Move nr_frags assignment a few lines down in order
>    to bundle index -> ring -> txq calculations together.
> 2. Readability: Add parentheses around nr_frags + 1.
> 3. Minor fix: Stop the Tx queue and throw the error message only if
>    the Tx queue hasn't already been stopped.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Applied.
